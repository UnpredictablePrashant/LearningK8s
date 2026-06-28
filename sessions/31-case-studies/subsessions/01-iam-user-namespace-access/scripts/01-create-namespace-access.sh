#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${IAM_USER_NAME:?Set IAM_USER_NAME to an existing IAM user name}"

NAMESPACE="${NAMESPACE:-case-team-a}"
K8S_GROUP="${K8S_GROUP:-eks-case-team-a-developers}"
ROLE_NAME="${ROLE_NAME:-EksCaseTeamANamespaceRole}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-EKSDescribeClusterForKubectl}"
USER_POLICY_NAME="${USER_POLICY_NAME:-AllowAssume${ROLE_NAME}}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
USER_ARN="arn:aws:iam::${ACCOUNT_ID}:user/${IAM_USER_NAME}"
CLUSTER_ARN="arn:aws:eks:${AWS_REGION}:${ACCOUNT_ID}:cluster/${CLUSTER_NAME}"

AUTH_MODE="$(aws eks describe-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --query 'cluster.accessConfig.authenticationMode' \
  --output text)"

if [[ "${AUTH_MODE}" != "API" && "${AUTH_MODE}" != "API_AND_CONFIG_MAP" ]]; then
  echo "Cluster authentication mode is ${AUTH_MODE}."
  echo "Enable EKS access entries first with authenticationMode=API_AND_CONFIG_MAP."
  exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

cat > "${WORK_DIR}/role-trust-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificIamUserToAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${USER_ARN}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON

cat > "${WORK_DIR}/role-describe-cluster-policy.json" <<JSON
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

cat > "${WORK_DIR}/user-assume-role-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeNamespaceAccessRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${ROLE_ARN}"
    }
  ]
}
JSON

if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "Updating trust policy for ${ROLE_NAME}"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "file://${WORK_DIR}/role-trust-policy.json"
else
  echo "Creating role ${ROLE_NAME}"
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "file://${WORK_DIR}/role-trust-policy.json" \
    --description "Case study role for namespace ${NAMESPACE} access in ${CLUSTER_NAME}" \
    >/dev/null
fi

echo "Putting role policy ${ROLE_POLICY_NAME}"
aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  --policy-document "file://${WORK_DIR}/role-describe-cluster-policy.json"

echo "Putting user policy ${USER_POLICY_NAME} on ${IAM_USER_NAME}"
aws iam put-user-policy \
  --user-name "${IAM_USER_NAME}" \
  --policy-name "${USER_POLICY_NAME}" \
  --policy-document "file://${WORK_DIR}/user-assume-role-policy.json"

if aws eks describe-access-entry \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --principal-arn "${ROLE_ARN}" >/dev/null 2>&1; then
  echo "Updating EKS access entry for ${ROLE_ARN}"
  aws eks update-access-entry \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --principal-arn "${ROLE_ARN}" \
    --kubernetes-groups "${K8S_GROUP}" \
    >/dev/null
else
  echo "Creating EKS access entry for ${ROLE_ARN}"
  aws eks create-access-entry \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --principal-arn "${ROLE_ARN}" \
    --type STANDARD \
    --kubernetes-groups "${K8S_GROUP}" \
    >/dev/null
fi

cat <<EOF

Namespace access role is ready.

Role ARN: ${ROLE_ARN}
Kubernetes group: ${K8S_GROUP}
Namespace: ${NAMESPACE}

Next:
  kubectl auth can-i list pods -n ${NAMESPACE} --as=case-study-check --as-group=${K8S_GROUP}

EOF
