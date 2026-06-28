#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-backup-restore}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-backup-restore|${NAMESPACE}|g" \
  "${CASE_DIR}/01-stateful-sample.yml" | kubectl apply -f -

kubectl rollout status deployment/backup-writer -n "${NAMESPACE}" --timeout=180s
kubectl get pods,pvc -n "${NAMESPACE}"
