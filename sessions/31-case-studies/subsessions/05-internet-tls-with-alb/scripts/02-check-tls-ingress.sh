#!/usr/bin/env bash
set -euo pipefail

: "${APP_HOSTNAME:?Set APP_HOSTNAME, for example app.example.com}"

NAMESPACE="${NAMESPACE:-case-tls-ingress}"

ALB_DNS_NAME="$(kubectl get ingress tls-demo \
  -n "${NAMESPACE}" \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

if [[ -z "${ALB_DNS_NAME}" ]]; then
  echo "Ingress does not have an ALB address yet."
  kubectl get ingress tls-demo -n "${NAMESPACE}"
  exit 1
fi

echo "Ingress ALB DNS name: ${ALB_DNS_NAME}"
echo "Checking HTTP redirect for http://${APP_HOSTNAME}"
curl -I "http://${APP_HOSTNAME}"

echo
echo "Checking HTTPS response for https://${APP_HOSTNAME}"
curl -Ik "https://${APP_HOSTNAME}"
