#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-autoscaling}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo "Autoscaling case study cleanup finished."
