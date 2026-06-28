#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"

ROLE_NAME="${ROLE_NAME:-EksBreakGlassAdminRole}"
SESSION_NAME="${SESSION_NAME:-break-glass-test}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="${ROLE_ARN:-arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}}"

read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN < <(
  aws sts assume-role \
    --role-arn "${ROLE_ARN}" \
    --role-session-name "${SESSION_NAME}" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
)

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

aws eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --alias "${CLUSTER_NAME}-break-glass" \
  >/dev/null

kubectl auth can-i '*' '*'
kubectl get namespaces
