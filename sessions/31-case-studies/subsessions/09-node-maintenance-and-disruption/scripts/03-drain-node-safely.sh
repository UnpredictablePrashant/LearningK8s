#!/usr/bin/env bash
set -euo pipefail

: "${NODE_NAME:?Set NODE_NAME to the node you intentionally want to drain}"

NAMESPACE="${NAMESPACE:-case-node-maintenance}"
CONFIRM_DRAIN="${CONFIRM_DRAIN:-false}"

if [[ "${CONFIRM_DRAIN}" != "true" ]]; then
  cat <<EOF
Refusing to drain ${NODE_NAME}.

Draining a node disrupts workloads. Inspect it first:
  kubectl get pods -A --field-selector spec.nodeName=${NODE_NAME} -o wide

Then explicitly confirm:
  export CONFIRM_DRAIN=true
  bash scripts/03-drain-node-safely.sh
EOF
  exit 1
fi

kubectl get pdb -n "${NAMESPACE}"
kubectl get pods -n "${NAMESPACE}" -o wide

kubectl cordon "${NODE_NAME}"
kubectl drain "${NODE_NAME}" \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --timeout=180s

kubectl get nodes
kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get pdb -n "${NAMESPACE}"
