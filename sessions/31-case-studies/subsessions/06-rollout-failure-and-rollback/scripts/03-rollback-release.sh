#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-rollout}"

kubectl rollout undo deployment/rollout-demo -n "${NAMESPACE}"
kubectl rollout status deployment/rollout-demo -n "${NAMESPACE}" --timeout=180s
kubectl get deployment,pods -n "${NAMESPACE}"
kubectl rollout history deployment/rollout-demo -n "${NAMESPACE}"
