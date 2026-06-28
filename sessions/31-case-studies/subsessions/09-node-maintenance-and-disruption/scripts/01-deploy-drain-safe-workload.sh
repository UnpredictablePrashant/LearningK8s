#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-node-maintenance}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-node-maintenance|${NAMESPACE}|g" \
  "${CASE_DIR}/01-drain-safe-workload.yml" | kubectl apply -f -

kubectl rollout status deployment/drain-safe-web -n "${NAMESPACE}" --timeout=180s
kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get pdb -n "${NAMESPACE}"
