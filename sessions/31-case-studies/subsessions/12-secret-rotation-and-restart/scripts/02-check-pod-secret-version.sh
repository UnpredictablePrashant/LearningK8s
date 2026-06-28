#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-secret-rotation}"

POD_NAME="$(kubectl get pod -n "${NAMESPACE}" \
  -l app.kubernetes.io/name=secret-aware-app \
  -o jsonpath='{.items[0].metadata.name}')"

kubectl exec -n "${NAMESPACE}" "${POD_NAME}" -- /bin/sh -c 'echo "APP_SECRET_VERSION=${APP_SECRET_VERSION}"'
