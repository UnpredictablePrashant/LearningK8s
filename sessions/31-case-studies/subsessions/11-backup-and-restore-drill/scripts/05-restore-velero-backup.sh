#!/usr/bin/env bash
set -euo pipefail

: "${BACKUP_NAME:?Set BACKUP_NAME printed by scripts/03-create-velero-backup.sh}"

NAMESPACE="${NAMESPACE:-case-backup-restore}"
RESTORE_NAME="${RESTORE_NAME:-restore-${BACKUP_NAME}}"

command -v velero >/dev/null

velero restore create "${RESTORE_NAME}" \
  --from-backup "${BACKUP_NAME}" \
  --wait

velero restore describe "${RESTORE_NAME}" --details
kubectl rollout status deployment/backup-writer -n "${NAMESPACE}" --timeout=180s

bash "$(dirname "${BASH_SOURCE[0]}")/02-verify-marker-file.sh"
