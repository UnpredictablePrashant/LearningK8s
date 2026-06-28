#!/usr/bin/env bash
set -euo pipefail

: "${APP_HOSTNAME:?Set APP_HOSTNAME, for example app.example.com}"
: "${ACM_CERT_ARN:?Set ACM_CERT_ARN to an ACM certificate ARN in the ALB region}"

NAMESPACE="${NAMESPACE:-case-tls-ingress}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

kubectl get ingressclass alb >/dev/null

sed \
  -e "s|case-tls-ingress|${NAMESPACE}|g" \
  "${CASE_DIR}/01-demo-app.yml" | kubectl apply -f -

kubectl rollout status deployment/tls-demo -n "${NAMESPACE}" --timeout=180s

sed \
  -e "s|case-tls-ingress|${NAMESPACE}|g" \
  -e "s|REPLACE_WITH_APP_HOSTNAME|${APP_HOSTNAME}|g" \
  -e "s|REPLACE_WITH_ACM_CERT_ARN|${ACM_CERT_ARN}|g" \
  "${CASE_DIR}/02-alb-tls-ingress.yml" | kubectl apply -f -

kubectl get ingress tls-demo -n "${NAMESPACE}"

cat <<EOF

Ingress applied.

Watch for the ALB address:
  kubectl get ingress tls-demo -n ${NAMESPACE} -w

Then point DNS for ${APP_HOSTNAME} to the ALB address.

EOF
