#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-cost-guardrails}"

kubectl get namespace "${NAMESPACE}" --show-labels
kubectl get all -n "${NAMESPACE}" \
  -L owner,cost-center,environment
kubectl describe resourcequota cost-quota -n "${NAMESPACE}"
