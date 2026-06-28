#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-backup-restore}"
DELETE_VELERO_BACKUP="${DELETE_VELERO_BACKUP:-false}"
BACKUP_NAME="${BACKUP_NAME:-}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found

if [[ "${DELETE_VELERO_BACKUP}" == "true" ]]; then
  : "${BACKUP_NAME:?Set BACKUP_NAME before deleting the Velero backup}"
  velero backup delete "${BACKUP_NAME}" --confirm
fi

echo "Backup and restore case study cleanup finished."
