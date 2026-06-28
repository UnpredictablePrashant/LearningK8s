#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-cost-guardrails}"

kubectl delete deployment runaway-workers -n "${NAMESPACE}" --ignore-not-found
kubectl describe resourcequota cost-quota -n "${NAMESPACE}" || true
