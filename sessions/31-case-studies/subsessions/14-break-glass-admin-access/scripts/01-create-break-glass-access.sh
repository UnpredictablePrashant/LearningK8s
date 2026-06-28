#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${BREAK_GLASS_PRINCIPAL_ARN:?Set BREAK_GLASS_PRINCIPAL_ARN to the trusted IAM principal ARN}"

CONFIRM_BREAK_GLASS="${CONFIRM_BREAK_GLASS:-false}"
ROLE_NAME="${ROLE_NAME:-EksBreakGlassAdminRole}"
K8S_GROUP="${K8S_GROUP:-case-break-glass-admins}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-DescribeClusterForBreakGlass}"
INCIDENT_ID="${INCIDENT_ID:-no-incident-id-provided}"

if [[ "${CONFIRM_BREAK_GLASS}" != "true" ]]; then
  cat <<EOF
Refusing to create break-glass admin access.

This grants cluster-admin through an EKS access entry and ClusterRoleBinding.
Confirm intentionally:
  export CONFIRM_BREAK_GLASS=true
  bash scripts/01-create-break-glass-access.sh
EOF
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
CLUSTER_ARN="arn:aws:eks:${AWS_REGION}:${ACCOUNT_ID}:cluster/${CLUSTER_NAME}"

AUTH_MODE="$(aws eks describe-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --query 'cluster.accessConfig.authenticationMode' \
  --output text)"

if [[ "${AUTH_MODE}" != "API" && "${AUTH_MODE}" != "API_AND_CONFIG_MAP" ]]; then
  echo "Cluster authentication mode is ${AUTH_MODE}."
  echo "Enable EKS access entries first."
  exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

cat > "${WORK_DIR}/trust-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowApprovedPrincipalToAssumeBreakGlassRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${BREAK_GLASS_PRINCIPAL_ARN}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON

cat > "${WORK_DIR}/describe-cluster-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDescribeOnlyThisEksCluster",
      "Effect": "Allow",
      "Action": "eks:DescribeCluster",
      "Resource": "${CLUSTER_ARN}"
    }
  ]
}
JSON

if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "Updating break-glass role ${ROLE_NAME}"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "file://${WORK_DIR}/trust-policy.json"
  aws iam update-role \
    --role-name "${ROLE_NAME}" \
    --max-session-duration 3600 \
    >/dev/null
else
  echo "Creating break-glass role ${ROLE_NAME}"
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "file://${WORK_DIR}/trust-policy.json" \
    --max-session-duration 3600 \
    --description "Break-glass EKS admin role for ${CLUSTER_NAME}; incident ${INCIDENT_ID}" \
    --tags Key=Purpose,Value=BreakGlass Key=Cluster,Value="${CLUSTER_NAME}" Key=IncidentId,Value="${INCIDENT_ID}" \
    >/dev/null
fi

aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  --policy-document "file://${WORK_DIR}/describe-cluster-policy.json"

if aws eks describe-access-entry \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --principal-arn "${ROLE_ARN}" >/dev/null 2>&1; then
  aws eks update-access-entry \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --principal-arn "${ROLE_ARN}" \
    --kubernetes-groups "${K8S_GROUP}" \
    >/dev/null
else
  aws eks create-access-entry \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --principal-arn "${ROLE_ARN}" \
    --type STANDARD \
    --kubernetes-groups "${K8S_GROUP}" \
    >/dev/null
fi

sed \
  -e "s|REPLACE_WITH_K8S_GROUP|${K8S_GROUP}|g" \
  "${CASE_DIR}/01-break-glass-rbac.yml" | kubectl apply -f -

cat <<EOF

Break-glass access is active.

Role ARN: ${ROLE_ARN}
Kubernetes group: ${K8S_GROUP}
Incident ID: ${INCIDENT_ID}

Test as the trusted principal:
  bash scripts/02-test-break-glass-access.sh

Revoke when the incident is over:
  export CONFIRM_REVOKE_BREAK_GLASS=true
  bash scripts/03-revoke-break-glass-access.sh

EOF
