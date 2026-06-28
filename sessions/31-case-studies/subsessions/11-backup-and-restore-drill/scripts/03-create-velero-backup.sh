#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-backup-restore}"
BACKUP_NAME="${BACKUP_NAME:-case-backup-restore-$(date +%Y%m%d%H%M%S)}"

command -v velero >/dev/null

velero backup create "${BACKUP_NAME}" \
  --include-namespaces "${NAMESPACE}" \
  --wait

velero backup describe "${BACKUP_NAME}" --details

cat <<EOF

Backup created.

export BACKUP_NAME=${BACKUP_NAME}

EOF
