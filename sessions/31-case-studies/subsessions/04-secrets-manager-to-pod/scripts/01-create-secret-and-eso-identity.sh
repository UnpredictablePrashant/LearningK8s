#!/usr/bin/env bash
set -euo pipefail

: "${CLUSTER_NAME:?Set CLUSTER_NAME, for example demo-batch16a}"
: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${SECRET_NAME:?Set SECRET_NAME, for example batch16a/case-study/app-runtime}"

SECRET_VALUE_JSON="${SECRET_VALUE_JSON:-{\"username\":\"app_user\",\"password\":\"ChangeMeForLabOnly123!\"}}"
ROLE_NAME="${ROLE_NAME:-EksExternalSecretsCaseStudyRole}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-ReadCaseStudySecretsManagerSecret}"
ESO_NAMESPACE="${ESO_NAMESPACE:-external-secrets}"
ESO_SERVICE_ACCOUNT="${ESO_SERVICE_ACCOUNT:-external-secrets}"
POD_IDENTITY_ADDON="${POD_IDENTITY_ADDON:-eks-pod-identity-agent}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

if SECRET_ARN="$(aws secretsmanager describe-secret \
  --region "${AWS_REGION}" \
  --secret-id "${SECRET_NAME}" \
  --query ARN \
  --output text 2>/dev/null)"; then
  echo "Updating existing Secrets Manager secret ${SECRET_NAME}"
  aws secretsmanager put-secret-value \
    --region "${AWS_REGION}" \
    --secret-id "${SECRET_NAME}" \
    --secret-string "${SECRET_VALUE_JSON}" \
    >/dev/null
else
  echo "Creating Secrets Manager secret ${SECRET_NAME}"
  SECRET_ARN="$(aws secretsmanager create-secret \
    --region "${AWS_REGION}" \
    --name "${SECRET_NAME}" \
    --secret-string "${SECRET_VALUE_JSON}" \
    --query ARN \
    --output text)"
fi

echo "Installing or upgrading External Secrets Operator"
helm repo add external-secrets https://charts.external-secrets.io >/dev/null 2>&1 || true
helm repo update external-secrets >/dev/null
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace "${ESO_NAMESPACE}" \
  --create-namespace \
  --set installCRDs=true \
  >/dev/null

kubectl rollout status deployment/external-secrets \
  -n "${ESO_NAMESPACE}" \
  --timeout=180s

if aws eks describe-addon \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --addon-name "${POD_IDENTITY_ADDON}" >/dev/null 2>&1; then
  echo "EKS add-on ${POD_IDENTITY_ADDON} already exists"
else
  echo "Creating EKS add-on ${POD_IDENTITY_ADDON}"
  aws eks create-addon \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --addon-name "${POD_IDENTITY_ADDON}" \
    >/dev/null
fi

echo "Waiting for ${POD_IDENTITY_ADDON} to become active"
aws eks wait addon-active \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --addon-name "${POD_IDENTITY_ADDON}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

cat > "${WORK_DIR}/external-secrets-trust-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowExternalSecretsControllerPodIdentity",
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:AssumeRole",
        "sts:TagSession"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/eks-cluster-name": "${CLUSTER_NAME}",
          "aws:RequestTag/kubernetes-namespace": "${ESO_NAMESPACE}",
          "aws:RequestTag/kubernetes-service-account": "${ESO_SERVICE_ACCOUNT}"
        }
      }
    }
  ]
}
JSON

cat > "${WORK_DIR}/secrets-manager-read-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyOneSecretsManagerSecret",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "${SECRET_ARN}"
    }
  ]
}
JSON

if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "Updating trust policy for ${ROLE_NAME}"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "file://${WORK_DIR}/external-secrets-trust-policy.json"
else
  echo "Creating role ${ROLE_NAME}"
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "file://${WORK_DIR}/external-secrets-trust-policy.json" \
    --description "Case study role for External Secrets access to ${SECRET_NAME}" \
    >/dev/null
fi

echo "Putting role policy ${ROLE_POLICY_NAME}"
aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_POLICY_NAME}" \
  --policy-document "file://${WORK_DIR}/secrets-manager-read-policy.json"

ASSOCIATION_ID="$(aws eks list-pod-identity-associations \
  --cluster-name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --namespace "${ESO_NAMESPACE}" \
  --service-account "${ESO_SERVICE_ACCOUNT}" \
  --query 'associations[0].associationId' \
  --output text)"

if [[ "${ASSOCIATION_ID}" == "None" || -z "${ASSOCIATION_ID}" ]]; then
  echo "Creating Pod Identity association for External Secrets Operator"
  aws eks create-pod-identity-association \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --namespace "${ESO_NAMESPACE}" \
    --service-account "${ESO_SERVICE_ACCOUNT}" \
    --role-arn "${ROLE_ARN}" \
    >/dev/null
else
  echo "Updating Pod Identity association ${ASSOCIATION_ID}"
  aws eks update-pod-identity-association \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --association-id "${ASSOCIATION_ID}" \
    --role-arn "${ROLE_ARN}" \
    >/dev/null
fi

echo "Restarting External Secrets Operator so it picks up Pod Identity credentials"
kubectl rollout restart deployment/external-secrets -n "${ESO_NAMESPACE}"
kubectl rollout status deployment/external-secrets -n "${ESO_NAMESPACE}" --timeout=180s

cat <<EOF

External Secrets access is ready.

Secret ARN: ${SECRET_ARN}
Controller role ARN: ${ROLE_ARN}

Next:
  bash scripts/02-sync-and-run-secret-check.sh

EOF
