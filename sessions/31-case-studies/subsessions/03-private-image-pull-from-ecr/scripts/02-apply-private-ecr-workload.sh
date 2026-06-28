#!/usr/bin/env bash
set -euo pipefail

: "${ECR_IMAGE_URI:?Set ECR_IMAGE_URI printed by scripts/01-build-and-push-ecr-image.sh}"

NAMESPACE="${NAMESPACE:-case-ecr-pull}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-ecr-pull|${NAMESPACE}|g" \
  "${CASE_DIR}/01-namespace.yml" | kubectl apply -f -

sed \
  -e "s|case-ecr-pull|${NAMESPACE}|g" \
  -e "s|REPLACE_WITH_ECR_IMAGE_URI|${ECR_IMAGE_URI}|g" \
  "${CASE_DIR}/02-private-ecr-deployment.yml" | kubectl apply -f -

kubectl rollout status deployment/private-ecr-app -n "${NAMESPACE}" --timeout=180s
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=private-ecr-app -o wide
