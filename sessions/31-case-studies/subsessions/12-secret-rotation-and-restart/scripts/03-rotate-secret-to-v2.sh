#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-secret-rotation}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-secret-rotation|${NAMESPACE}|g" \
  "${CASE_DIR}/03-secret-v2.yml" | kubectl apply -f -

kubectl get secret app-runtime-secret -n "${NAMESPACE}"

cat <<'EOF'

Secret object was updated.
Existing Pods that use env vars still have the old value until they restart.

Check:
  bash scripts/02-check-pod-secret-version.sh

EOF
