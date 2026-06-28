# AWS Integrated Secure Workloads Capstone

Capstone Level: 2 of 5

## Problem Statement

The application now runs in Kubernetes, but it still needs secure access to AWS
services. Your team must connect Pods and platform controllers to AWS without
static credentials, apply least-privilege IAM, externalize secrets, and prove
that allowed and denied access behave as expected.

## Estimated Effort

8 to 12 hours for a focused team. Expect meaningful time spent on IAM policy
design, trust relationships, validation, and denied-access testing.

## Required Scope

- Give each application tier its own Kubernetes ServiceAccount.
- Use EKS Pod Identity or IRSA for workload access to AWS.
- Store database credentials in AWS Secrets Manager or SSM Parameter Store.
- Sync or mount secrets into Kubernetes using External Secrets Operator or
  Secrets Store CSI Driver.
- Encrypt sensitive AWS resources with KMS.
- Give one workload read access to a specific S3 bucket prefix.
- Add an explicit denied-access test for a different bucket, prefix, or secret.
- Configure IAM permissions for required add-ons such as the AWS Load Balancer
  Controller, EBS CSI driver, and ExternalDNS.
- Use EKS access entries or a documented access mapping for human operators.
- Create an audit checklist for IAM roles, Kubernetes RBAC, and secret access.

## AWS Touchpoints

- IAM roles, IAM policies, and trust policies.
- EKS Pod Identity associations or IAM OIDC provider for IRSA.
- AWS Secrets Manager or SSM Parameter Store.
- KMS key policy for secret and bucket encryption.
- S3 bucket and prefix policy.
- AWS Load Balancer Controller IAM permissions.
- EBS CSI driver IAM permissions.
- ExternalDNS IAM permissions for Route 53 when DNS is used.
- CloudTrail events for STS, Secrets Manager, S3, and IAM role usage.

## Kubernetes Requirements

- ServiceAccounts mapped to specific AWS IAM roles.
- ExternalSecret, SecretProviderClass, or equivalent secret integration.
- RBAC Roles and RoleBindings that match each app tier.
- NetworkPolicy from Level 1 remains active.
- A validation Job or temporary Pod that calls AWS STS and the target AWS
  service.

## Deliverables

- IAM policy JSON for each workload and controller role.
- Trust policy JSON for each workload identity path.
- Kubernetes manifests for ServiceAccounts, identity associations, and secret
  integration.
- Validation scripts or commands for allowed and denied AWS access.
- Audit notes showing which principal can read each secret, bucket prefix, and
  Kubernetes resource.
- Cleanup commands for AWS and Kubernetes resources.

## Acceptance Criteria

- No Pod uses long-lived AWS access keys.
- Each workload can call `sts get-caller-identity` and shows the intended role.
- The allowed S3 or secret access succeeds.
- The denied S3 or secret access fails with an authorization error.
- Platform add-ons have only the permissions required for their controller.
- A human operator has Kubernetes access through an approved AWS identity path.

## Suggested Work Breakdown

1. Inventory every AWS permission the app and controllers need.
2. Design IAM roles, policies, and trust policies.
3. Bind Kubernetes ServiceAccounts to AWS identities.
4. Externalize database credentials.
5. Add S3 access and denied-access tests.
6. Validate CloudTrail and Kubernetes evidence.
7. Write the security handoff.

## Review Prompts

1. Why is Kubernetes RBAC not enough for S3 or Secrets Manager access?
2. Which IAM role would be most dangerous if compromised?
3. What prevents a frontend Pod from reading database credentials directly?
4. How would you rotate the database password?
5. Which CloudTrail events prove the workload used the intended identity?
