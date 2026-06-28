#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${S3_BUCKET:?Set S3_BUCKET to an existing bucket name}"

NAMESPACE="${NAMESPACE:-case-s3-access}"
SERVICE_ACCOUNT="${SERVICE_ACCOUNT:-s3-client}"
ROLE_NAME="${ROLE_NAME:-EksPodS3CaseStudyRole}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-S3CaseStudyBucketAccess}"
S3_PREFIX="${S3_PREFIX:-pod-identity-check}"
POD_IDENTITY_ADDON="${POD_IDENTITY_ADDON:-eks-pod-identity-agent}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

echo "Checking S3 bucket ${S3_BUCKET}"
aws s3api head-bucket --bucket "${S3_BUCKET}" >/dev/null

echo "Applying Kubernetes Namespace and ServiceAccount"
kubectl apply -f "${CASE_DIR}/01-namespace-and-serviceaccount.yml"

if aws eks describe-addon \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --addon-name "${POD_IDENTITY_ADDON}" >/dev/null 2>&1; then
  echo "EKS add-on ${POD_IDENTITY_ADDON} already exists"
else
  echo "Creating EKS add-on ${POD_IDENTITY_ADDON}"
  aws eks create-addon \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --addon-name "${POD_IDENTITY_ADDON}" \
    >/dev/null
fi

echo "Waiting for ${POD_IDENTITY_ADDON} to become active"
aws eks wait addon-active \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --addon-name "${POD_IDENTITY_ADDON}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

cat > "${WORK_DIR}/pod-identity-trust-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEksPodIdentityForSpecificWorkload",
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:AssumeRole",
        "sts:TagSession"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/eks-cluster-name": "${CLUSTER_NAME}",
          "aws:RequestTag/kubernetes-namespace": "${NAMESPACE}",
          "aws:RequestTag/kubernetes-service-account": "${SERVICE_ACCOUNT}"
        }
      }
    }
  ]
}
JSON

cat > "${WORK_DIR}/s3-prefix-access-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListOnlyTheApplicationPrefix",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${S3_BUCKET}",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "${S3_PREFIX}",
            "${S3_PREFIX}/*"
          ]
        }
      }
    },
    {
      "Sid": "ReadWriteOnlyTheApplicationPrefix",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${S3_BUCKET}/${S3_PREFIX}/*"
    }
  ]
}
JSON

if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "Updating trust policy for ${ROLE_NAME}"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "file://${WORK_DIR}/pod-identity-trust-policy.json"
else
  echo "Creating role ${ROLE_NAME}"
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "file://${WORK_DIR}/pod-identity-trust-policy.json" \
    --description "Case study role for EKS Pod access to S3 prefix ${S3_BUCKET}/${S3_PREFIX}" \
    >/dev/null
fi

echo "Putting role policy ${ROLE_POLICY_NAME}"
aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  --policy-document "file://${WORK_DIR}/s3-prefix-access-policy.json"

ASSOCIATION_ID="$(aws eks list-pod-identity-associations \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --namespace "${NAMESPACE}" \
  --service-account "${SERVICE_ACCOUNT}" \
  --query 'associations[0].associationId' \
  --output text)"

if [[ "${ASSOCIATION_ID}" == "None" || -z "${ASSOCIATION_ID}" ]]; then
  echo "Creating Pod Identity association"
  aws eks create-pod-identity-association \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --namespace "${NAMESPACE}" \
    --service-account "${SERVICE_ACCOUNT}" \
    --role-arn "${ROLE_ARN}" \
    >/dev/null
else
  echo "Updating Pod Identity association ${ASSOCIATION_ID}"
  aws eks update-pod-identity-association \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --association-id "${ASSOCIATION_ID}" \
    --role-arn "${ROLE_ARN}" \
    >/dev/null
fi

cat <<EOF

S3 Pod Identity access is ready.

Namespace: ${NAMESPACE}
ServiceAccount: ${SERVICE_ACCOUNT}
Role ARN: ${ROLE_ARN}
Allowed S3 path: s3://${S3_BUCKET}/${S3_PREFIX}/

Next:
  bash scripts/02-run-s3-access-check.sh

EOF
