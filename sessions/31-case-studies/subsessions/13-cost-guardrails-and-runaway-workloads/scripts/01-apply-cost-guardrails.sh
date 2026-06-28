#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-cost-guardrails}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-cost-guardrails|${NAMESPACE}|g" \
  "${CASE_DIR}/01-cost-guardrails.yml" | kubectl apply -f -

kubectl rollout status deployment/cost-aware-app -n "${NAMESPACE}" --timeout=180s
kubectl get deployment,service,hpa,resourcequota,limitrange -n "${NAMESPACE}"
