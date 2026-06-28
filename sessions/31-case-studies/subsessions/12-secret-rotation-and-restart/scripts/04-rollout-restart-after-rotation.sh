#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-secret-rotation}"

kubectl rollout restart deployment/secret-aware-app -n "${NAMESPACE}"
kubectl rollout status deployment/secret-aware-app -n "${NAMESPACE}" --timeout=180s
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=secret-aware-app
