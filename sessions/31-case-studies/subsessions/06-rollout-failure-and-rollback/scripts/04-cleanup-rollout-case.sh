#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-rollout}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo "Rollout failure case study cleanup finished."
