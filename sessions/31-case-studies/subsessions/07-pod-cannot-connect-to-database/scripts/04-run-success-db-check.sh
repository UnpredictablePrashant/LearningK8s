#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-db-connectivity}"
JOB_NAME="${JOB_NAME:-db-connectivity-check}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

kubectl delete job "${JOB_NAME}" -n "${NAMESPACE}" --ignore-not-found

sed \
  -e "s|case-db-connectivity|${NAMESPACE}|g" \
  "${CASE_DIR}/02-db-connectivity-check-job.yml" | kubectl apply -f -

if kubectl wait --for=condition=complete "job/${JOB_NAME}" -n "${NAMESPACE}" --timeout=120s; then
  kubectl logs "job/${JOB_NAME}" -n "${NAMESPACE}"
else
  kubectl describe "job/${JOB_NAME}" -n "${NAMESPACE}" || true
  kubectl logs "job/${JOB_NAME}" -n "${NAMESPACE}" --all-containers=true || true
  exit 1
fi
