#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${S3_BUCKET:?Set S3_BUCKET to the existing bucket name}"

NAMESPACE="${NAMESPACE:-case-s3-access}"
S3_PREFIX="${S3_PREFIX:-pod-identity-check}"
JOB_NAME="${JOB_NAME:-s3-access-check}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

kubectl delete job "${JOB_NAME}" -n "${NAMESPACE}" --ignore-not-found

sed \
  -e "s|REPLACE_WITH_AWS_REGION|${AWS_REGION}|g" \
  -e "s|REPLACE_WITH_BUCKET_NAME|${S3_BUCKET}|g" \
  -e "s|pod-identity-check|${S3_PREFIX}|g" \
  "${CASE_DIR}/02-s3-access-check-job.yml" | kubectl apply -f -

if kubectl wait \
  --for=condition=complete \
  "job/${JOB_NAME}" \
  -n "${NAMESPACE}" \
  --timeout=180s; then
  kubectl logs "job/${JOB_NAME}" -n "${NAMESPACE}"
else
  kubectl describe "job/${JOB_NAME}" -n "${NAMESPACE}" || true
  kubectl logs "job/${JOB_NAME}" -n "${NAMESPACE}" --all-containers=true || true
  exit 1
fi
