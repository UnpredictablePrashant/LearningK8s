#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-rollout}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-rollout|${NAMESPACE}|g" \
  "${CASE_DIR}/02-bad-release.yml" | kubectl apply -f -

if kubectl rollout status deployment/rollout-demo -n "${NAMESPACE}" --timeout=75s; then
  echo "Unexpected success. The bad image rollout completed."
  exit 1
fi

echo
echo "Rollout failed as expected. Collecting evidence."
kubectl get deployment rollout-demo -n "${NAMESPACE}"
kubectl get replicasets -n "${NAMESPACE}"
kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get events -n "${NAMESPACE}" --sort-by=.lastTimestamp | tail -n 20
kubectl rollout history deployment/rollout-demo -n "${NAMESPACE}"
