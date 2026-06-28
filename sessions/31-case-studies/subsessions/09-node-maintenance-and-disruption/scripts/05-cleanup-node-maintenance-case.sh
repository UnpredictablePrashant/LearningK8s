#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-node-maintenance}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo "Node maintenance case study cleanup finished."
