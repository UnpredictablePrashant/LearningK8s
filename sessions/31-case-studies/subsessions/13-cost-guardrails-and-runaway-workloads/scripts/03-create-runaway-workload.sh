#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-cost-guardrails}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-cost-guardrails|${NAMESPACE}|g" \
  "${CASE_DIR}/02-runaway-workload.yml" | kubectl apply -f -

sleep 5

kubectl get deployment runaway-workers -n "${NAMESPACE}"
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=runaway-workers
kubectl describe resourcequota cost-quota -n "${NAMESPACE}"
kubectl get events -n "${NAMESPACE}" --sort-by=.lastTimestamp | tail -n 20
