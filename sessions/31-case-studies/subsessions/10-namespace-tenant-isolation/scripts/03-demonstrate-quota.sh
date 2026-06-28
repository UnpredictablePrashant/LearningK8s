#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

kubectl apply -f "${CASE_DIR}/03-quota-burst.yml"

sleep 5

kubectl get deployment quota-burst -n case-tenant-a
kubectl get pods -n case-tenant-a -l app.kubernetes.io/name=quota-burst
kubectl describe resourcequota tenant-quota -n case-tenant-a
kubectl get events -n case-tenant-a --sort-by=.lastTimestamp | tail -n 20

cat <<'EOF'

Cleanup the quota pressure Deployment when finished:
  kubectl delete deployment quota-burst -n case-tenant-a

EOF
