#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${SECRET_NAME:?Set SECRET_NAME, for example batch16a/case-study/app-runtime}"

APP_NAMESPACE="${APP_NAMESPACE:-case-secrets-app}"
JOB_NAME="${JOB_NAME:-secret-consumer-check}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-secrets-app|${APP_NAMESPACE}|g" \
  "${CASE_DIR}/01-app-namespace.yml" | kubectl apply -f -

sed \
  -e "s|case-secrets-app|${APP_NAMESPACE}|g" \
  -e "s|REPLACE_WITH_AWS_REGION|${AWS_REGION}|g" \
  -e "s|REPLACE_WITH_SECRET_NAME|${SECRET_NAME}|g" \
  "${CASE_DIR}/02-external-secret.yml" | kubectl apply -f -

echo "Waiting for Kubernetes Secret app-runtime-secret in ${APP_NAMESPACE}"
for _ in $(seq 1 60); do
  if kubectl get secret app-runtime-secret -n "${APP_NAMESPACE}" >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

kubectl get secret app-runtime-secret -n "${APP_NAMESPACE}" >/dev/null

kubectl delete job "${JOB_NAME}" -n "${APP_NAMESPACE}" --ignore-not-found

sed \
  -e "s|case-secrets-app|${APP_NAMESPACE}|g" \
  "${CASE_DIR}/03-secret-consumer-check-job.yml" | kubectl apply -f -

if kubectl wait \
  --for=condition=complete \
  "job/${JOB_NAME}" \
  -n "${APP_NAMESPACE}" \
  --timeout=120s; then
  kubectl logs "job/${JOB_NAME}" -n "${APP_NAMESPACE}"
else
  kubectl describe "job/${JOB_NAME}" -n "${APP_NAMESPACE}" || true
  kubectl logs "job/${JOB_NAME}" -n "${APP_NAMESPACE}" --all-containers=true || true
  exit 1
fi
