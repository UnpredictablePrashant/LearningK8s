#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-autoscaling}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if ! kubectl top nodes >/dev/null 2>&1; then
  echo "Warning: kubectl top nodes failed. Metrics Server may not be ready."
  echo "HPA needs resource metrics before it can scale from CPU utilization."
fi

sed \
  -e "s|case-autoscaling|${NAMESPACE}|g" \
  "${CASE_DIR}/01-autoscaling-target.yml" | kubectl apply -f -

sed \
  -e "s|case-autoscaling|${NAMESPACE}|g" \
  "${CASE_DIR}/02-hpa.yml" | kubectl apply -f -

kubectl rollout status deployment/scale-demo -n "${NAMESPACE}" --timeout=180s
kubectl get deployment,service,hpa -n "${NAMESPACE}"
kubectl describe hpa scale-demo -n "${NAMESPACE}" || true
