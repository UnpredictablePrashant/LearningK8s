#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-db-connectivity}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-db-connectivity|${NAMESPACE}|g" \
  "${CASE_DIR}/03-fixed-database-service.yml" | kubectl apply -f -

for _ in $(seq 1 30); do
  ENDPOINT_IP="$(kubectl get endpoints postgres-db \
    -n "${NAMESPACE}" \
    -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null || true)"
  if [[ -n "${ENDPOINT_IP}" ]]; then
    break
  fi
  sleep 2
done

kubectl get service,endpoints -n "${NAMESPACE}" postgres-db
kubectl get endpointslices -n "${NAMESPACE}" -l kubernetes.io/service-name=postgres-db
