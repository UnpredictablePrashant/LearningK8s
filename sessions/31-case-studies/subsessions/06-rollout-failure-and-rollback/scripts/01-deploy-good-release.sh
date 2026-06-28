#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-rollout}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-rollout|${NAMESPACE}|g" \
  "${CASE_DIR}/01-good-release.yml" | kubectl apply -f -

kubectl rollout status deployment/rollout-demo -n "${NAMESPACE}" --timeout=180s
kubectl get deployment,pods,service -n "${NAMESPACE}"
kubectl rollout history deployment/rollout-demo -n "${NAMESPACE}"
