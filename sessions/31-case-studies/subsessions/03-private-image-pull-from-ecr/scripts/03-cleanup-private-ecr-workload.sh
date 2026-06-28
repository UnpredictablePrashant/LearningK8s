#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-ecr-pull}"
DELETE_ECR_REPOSITORY="${DELETE_ECR_REPOSITORY:-false}"
AWS_REGION="${AWS_REGION:-}"
ECR_REPOSITORY="${ECR_REPOSITORY:-}"

kubectl delete service private-ecr-app -n "${NAMESPACE}" --ignore-not-found
kubectl delete deployment private-ecr-app -n "${NAMESPACE}" --ignore-not-found
kubectl delete namespace "${NAMESPACE}" --ignore-not-found

if [[ "${DELETE_ECR_REPOSITORY}" == "true" ]]; then
  : "${AWS_REGION:?Set AWS_REGION before deleting the ECR repository}"
  : "${ECR_REPOSITORY:?Set ECR_REPOSITORY before deleting the ECR repository}"

  aws ecr delete-repository \
    --region "${AWS_REGION}" \
    --repository-name "${ECR_REPOSITORY}" \
    --force \
    >/dev/null
fi

echo "Private ECR workload cleanup finished."
