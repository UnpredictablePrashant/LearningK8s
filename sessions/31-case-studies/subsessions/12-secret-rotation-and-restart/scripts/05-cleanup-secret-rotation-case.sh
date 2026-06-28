#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-secret-rotation}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo "Secret rotation case study cleanup finished."
