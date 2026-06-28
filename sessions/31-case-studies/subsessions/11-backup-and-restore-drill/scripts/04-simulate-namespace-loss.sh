#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-backup-restore}"
CONFIRM_DELETE_NAMESPACE="${CONFIRM_DELETE_NAMESPACE:-false}"

if [[ "${CONFIRM_DELETE_NAMESPACE}" != "true" ]]; then
  cat <<EOF
Refusing to delete namespace ${NAMESPACE}.

This script simulates data loss for the lab namespace.
Confirm intentionally:
  export CONFIRM_DELETE_NAMESPACE=true
  bash scripts/04-simulate-namespace-loss.sh
EOF
  exit 1
fi

kubectl delete namespace "${NAMESPACE}" --wait=true
echo "Namespace ${NAMESPACE} deleted."
