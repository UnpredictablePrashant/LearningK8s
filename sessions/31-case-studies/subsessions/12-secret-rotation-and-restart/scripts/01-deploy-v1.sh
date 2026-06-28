#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-secret-rotation}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-secret-rotation|${NAMESPACE}|g" \
  "${CASE_DIR}/01-secret-v1.yml" | kubectl apply -f -

sed \
  -e "s|case-secret-rotation|${NAMESPACE}|g" \
  "${CASE_DIR}/02-secret-aware-app.yml" | kubectl apply -f -

kubectl rollout status deployment/secret-aware-app -n "${NAMESPACE}" --timeout=180s
kubectl get deployment,pods,secret -n "${NAMESPACE}"
