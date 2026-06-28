#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"

APP_NAMESPACE="${APP_NAMESPACE:-case-secrets-app}"
JOB_NAME="${JOB_NAME:-secret-consumer-check}"
ROLE_NAME="${ROLE_NAME:-EksExternalSecretsCaseStudyRole}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-ReadCaseStudySecretsManagerSecret}"
ESO_NAMESPACE="${ESO_NAMESPACE:-external-secrets}"
ESO_SERVICE_ACCOUNT="${ESO_SERVICE_ACCOUNT:-external-secrets}"
DELETE_AWS_SECRET="${DELETE_AWS_SECRET:-false}"
SECRET_NAME="${SECRET_NAME:-}"

kubectl delete job "${JOB_NAME}" -n "${APP_NAMESPACE}" --ignore-not-found
kubectl delete externalsecret app-runtime-secret -n "${APP_NAMESPACE}" --ignore-not-found || true
kubectl delete secretstore aws-secrets-manager -n "${APP_NAMESPACE}" --ignore-not-found || true
kubectl delete secret app-runtime-secret -n "${APP_NAMESPACE}" --ignore-not-found
kubectl delete namespace "${APP_NAMESPACE}" --ignore-not-found

ASSOCIATION_ID="$(aws eks list-pod-identity-associations \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --namespace "${ESO_NAMESPACE}" \
  --service-account "${ESO_SERVICE_ACCOUNT}" \
  --query 'associations[0].associationId' \
  --output text 2>/dev/null || true)"

if [[ "${ASSOCIATION_ID}" != "None" && -n "${ASSOCIATION_ID}" ]]; then
  aws eks delete-pod-identity-association \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --association-id "${ASSOCIATION_ID}" \
    >/dev/null
fi

aws iam delete-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  >/dev/null 2>&1 || true

aws iam delete-role \
  --role-name "${ROLE_NAME}" \
  >/dev/null 2>&1 || true

if [[ "${DELETE_AWS_SECRET}" == "true" ]]; then
  : "${SECRET_NAME:?Set SECRET_NAME before deleting the Secrets Manager secret}"
  aws secretsmanager delete-secret \
    --region "${AWS_REGION}" \
    --secret-id "${SECRET_NAME}" \
    --force-delete-without-recovery \
    >/dev/null
fi

echo "Secrets Manager case study cleanup finished."
