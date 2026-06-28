#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"

CONFIRM_REVOKE_BREAK_GLASS="${CONFIRM_REVOKE_BREAK_GLASS:-false}"
ROLE_NAME="${ROLE_NAME:-EksBreakGlassAdminRole}"
K8S_GROUP="${K8S_GROUP:-case-break-glass-admins}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-DescribeClusterForBreakGlass}"

if [[ "${CONFIRM_REVOKE_BREAK_GLASS}" != "true" ]]; then
  cat <<EOF
Refusing to revoke break-glass access without confirmation.

Confirm intentionally:
  export CONFIRM_REVOKE_BREAK_GLASS=true
  bash scripts/03-revoke-break-glass-access.sh
EOF
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

kubectl delete clusterrolebinding case-break-glass-admins-cluster-admin --ignore-not-found

aws eks delete-access-entry \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --principal-arn "${ROLE_ARN}" \
  >/dev/null 2>&1 || true

aws iam delete-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  >/dev/null 2>&1 || true

aws iam delete-role \
  --role-name "${ROLE_NAME}" \
  >/dev/null 2>&1 || true

echo "Break-glass access for group ${K8S_GROUP} and role ${ROLE_ARN} was revoked."
