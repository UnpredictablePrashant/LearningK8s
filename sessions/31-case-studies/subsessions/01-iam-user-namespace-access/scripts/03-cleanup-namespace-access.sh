#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${IAM_USER_NAME:?Set IAM_USER_NAME to the IAM user used in the lab}"

ROLE_NAME="${ROLE_NAME:-EksCaseTeamANamespaceRole}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-EKSDescribeClusterForKubectl}"
USER_POLICY_NAME="${USER_POLICY_NAME:-AllowAssume${ROLE_NAME}}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

aws eks delete-access-entry \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --principal-arn "${ROLE_ARN}" \
  >/dev/null 2>&1 || true

aws iam delete-user-policy \
  --user-name "${IAM_USER_NAME}" \
  --policy-name "${USER_POLICY_NAME}" \
  >/dev/null 2>&1 || true

aws iam delete-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  >/dev/null 2>&1 || true

aws iam delete-role \
  --role-name "${ROLE_NAME}" \
  >/dev/null 2>&1 || true

kubectl delete -f 02-namespace-rbac.yml --ignore-not-found
kubectl delete -f 01-namespace.yml --ignore-not-found

echo "Case study IAM and Kubernetes resources were removed."
