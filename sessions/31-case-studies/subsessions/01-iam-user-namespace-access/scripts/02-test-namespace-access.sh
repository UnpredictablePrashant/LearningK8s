#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"

NAMESPACE="${NAMESPACE:-case-team-a}"
ROLE_NAME="${ROLE_NAME:-EksCaseTeamANamespaceRole}"
SESSION_NAME="${SESSION_NAME:-case-team-a-lab}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="${ROLE_ARN:-arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}}"

echo "Assuming ${ROLE_ARN}"
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
  --alias "${CLUSTER_NAME}-${NAMESPACE}-role" \
  >/dev/null

echo
echo "Allowed checks"
kubectl get pods -n "${NAMESPACE}"
kubectl auth can-i list pods -n "${NAMESPACE}"
kubectl auth can-i patch deployments.apps -n "${NAMESPACE}"

echo
echo "Denied checks"
kubectl auth can-i list pods -n default
kubectl auth can-i list nodes
