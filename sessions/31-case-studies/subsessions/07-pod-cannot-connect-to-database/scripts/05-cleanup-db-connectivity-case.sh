#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-db-connectivity}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo "Database connectivity case study cleanup finished."
