#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"

NAMESPACE="${NAMESPACE:-case-s3-access}"
SERVICE_ACCOUNT="${SERVICE_ACCOUNT:-s3-client}"
ROLE_NAME="${ROLE_NAME:-EksPodS3CaseStudyRole}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-S3CaseStudyBucketAccess}"
ALLOW_JOB_NAME="${ALLOW_JOB_NAME:-s3-access-check}"
DENY_JOB_NAME="${DENY_JOB_NAME:-s3-deny-check}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ASSOCIATION_ID="$(aws eks list-pod-identity-associations \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --namespace "${NAMESPACE}" \
  --service-account "${SERVICE_ACCOUNT}" \
  --query 'associations[0].associationId' \
  --output text 2>/dev/null || true)"

if [[ "${ASSOCIATION_ID}" != "None" && -n "${ASSOCIATION_ID}" ]]; then
  aws eks delete-pod-identity-association \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --association-id "${ASSOCIATION_ID}" \
    >/dev/null
fi

aws iam delete-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  >/dev/null 2>&1 || true

aws iam delete-role \
  --role-name "${ROLE_NAME}" \
  >/dev/null 2>&1 || true

kubectl delete job "${ALLOW_JOB_NAME}" -n "${NAMESPACE}" --ignore-not-found
kubectl delete job "${DENY_JOB_NAME}" -n "${NAMESPACE}" --ignore-not-found
kubectl delete -f "${CASE_DIR}/01-namespace-and-serviceaccount.yml" --ignore-not-found

echo "S3 Pod Identity case study resources were removed."
