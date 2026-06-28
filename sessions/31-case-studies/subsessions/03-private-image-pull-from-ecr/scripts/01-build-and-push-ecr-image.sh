#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:?Set AWS_REGION, for example us-east-2}"
: "${ECR_REPOSITORY:?Set ECR_REPOSITORY, for example batch16a/private-ecr-app}"

CLUSTER_NAME="${CLUSTER_NAME:-}"
NODE_ROLE_NAME="${NODE_ROLE_NAME:-}"
NODEGROUP_NAME="${NODEGROUP_NAME:-}"
IMAGE_TAG="${IMAGE_TAG:-v1}"
ROLE_POLICY_NAME="${ROLE_POLICY_NAME:-CaseStudyEcrPullPolicy}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${CASE_DIR}/../../../.." && pwd)"
BUILD_CONTEXT="${BUILD_CONTEXT:-${REPO_ROOT}/app/frontend}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_IMAGE_URI="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
REPOSITORY_ARN="arn:aws:ecr:${AWS_REGION}:${ACCOUNT_ID}:repository/${ECR_REPOSITORY}"

if aws ecr describe-repositories \
  --region "${AWS_REGION}" \
  --repository-names "${ECR_REPOSITORY}" >/dev/null 2>&1; then
  echo "ECR repository ${ECR_REPOSITORY} already exists"
else
  echo "Creating ECR repository ${ECR_REPOSITORY}"
  aws ecr create-repository \
    --region "${AWS_REGION}" \
    --repository-name "${ECR_REPOSITORY}" \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256 \
    >/dev/null
fi

echo "Logging Docker in to ${ECR_REGISTRY}"
aws ecr get-login-password --region "${AWS_REGION}" |
  docker login --username AWS --password-stdin "${ECR_REGISTRY}"

echo "Building ${ECR_IMAGE_URI} from ${BUILD_CONTEXT}"
docker build -t "${ECR_IMAGE_URI}" "${BUILD_CONTEXT}"

echo "Pushing ${ECR_IMAGE_URI}"
docker push "${ECR_IMAGE_URI}"

if [[ -z "${NODE_ROLE_NAME}" && -n "${NODEGROUP_NAME}" && -n "${CLUSTER_NAME}" ]]; then
  NODE_ROLE_ARN="$(aws eks describe-nodegroup \
    --cluster-name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --nodegroup-name "${NODEGROUP_NAME}" \
    --query 'nodegroup.nodeRole' \
    --output text)"
  NODE_ROLE_NAME="${NODE_ROLE_ARN##*/}"
fi

if [[ -n "${NODE_ROLE_NAME}" ]]; then
  WORK_DIR="$(mktemp -d)"
  trap 'rm -rf "${WORK_DIR}"' EXIT

  cat > "${WORK_DIR}/node-ecr-pull-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEcrAuthTokenForImagePull",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Sid": "AllowPullFromOneRepository",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "${REPOSITORY_ARN}"
    }
  ]
}
JSON

  echo "Attaching ECR pull policy ${ROLE_POLICY_NAME} to node role ${NODE_ROLE_NAME}"
  aws iam put-role-policy \
    --role-name "${NODE_ROLE_NAME}" \
    --policy-name "${ROLE_POLICY_NAME}" \
    --policy-document "file://${WORK_DIR}/node-ecr-pull-policy.json"
else
  echo "NODE_ROLE_NAME or NODEGROUP_NAME was not set, so no node IAM policy was changed."
  echo "If image pulls fail, attach ECR pull permissions to the node role or Fargate pod execution role."
fi

cat <<EOF

Private ECR image is ready.

ECR_IMAGE_URI=${ECR_IMAGE_URI}

Next:
  export ECR_IMAGE_URI=${ECR_IMAGE_URI}
  bash scripts/02-apply-private-ecr-workload.sh

EOF
