#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-db-connectivity}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-db-connectivity|${NAMESPACE}|g" \
  "${CASE_DIR}/01-broken-database-stack.yml" | kubectl apply -f -

kubectl rollout status deployment/postgres-db -n "${NAMESPACE}" --timeout=180s
kubectl get pods,service,endpoints -n "${NAMESPACE}"
kubectl get pods -n "${NAMESPACE}" --show-labels
