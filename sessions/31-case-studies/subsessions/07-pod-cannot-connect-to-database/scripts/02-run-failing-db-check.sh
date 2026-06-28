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

if kubectl wait --for=condition=complete "job/${JOB_NAME}" -n "${NAMESPACE}" --timeout=90s; then
  echo "Unexpected success. The broken Service should not have allowed DB connectivity."
  kubectl logs "job/${JOB_NAME}" -n "${NAMESPACE}"
  exit 1
fi

echo "Connectivity failed as expected. Evidence:"
kubectl logs "job/${JOB_NAME}" -n "${NAMESPACE}" --all-containers=true || true
kubectl get service postgres-db -n "${NAMESPACE}" -o wide
kubectl describe service postgres-db -n "${NAMESPACE}"
kubectl get endpoints postgres-db -n "${NAMESPACE}"
kubectl get pods -n "${NAMESPACE}" --show-labels
