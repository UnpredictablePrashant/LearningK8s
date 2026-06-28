#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-backup-restore}"

POD_NAME="$(kubectl get pod -n "${NAMESPACE}" \
  -l app.kubernetes.io/name=backup-writer \
  -o jsonpath='{.items[0].metadata.name}')"

kubectl exec -n "${NAMESPACE}" "${POD_NAME}" -- cat /data/restore-marker.txt
