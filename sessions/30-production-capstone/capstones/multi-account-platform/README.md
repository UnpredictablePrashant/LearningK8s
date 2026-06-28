# Multi-Account Platform Capstone

Capstone Level: 4 of 5

## Problem Statement

The company has outgrown a single AWS account. Your team must design and build
a platform where development, staging, production, shared tooling, and audit
responsibilities are separated across AWS accounts while Kubernetes delivery
still feels consistent for application teams.

## Estimated Effort

14 to 20 hours. This capstone should feel like a two-day workshop because it
requires account boundaries, IAM trust, GitOps access, DNS, image distribution,
secrets, audit, and operational proof.

## Reference Account Model

- `tooling`: CI roles, Argo CD, shared ECR, artifact buckets, and platform
  automation.
- `dev`: development EKS cluster and lower-risk AWS resources.
- `stage`: staging EKS cluster and production-like validation resources.
- `prod`: production EKS cluster and production data resources.
- `audit`: CloudTrail, log archive, security findings, and read-only evidence.

If real multi-account access is unavailable, model the accounts in diagrams and
IAM JSON. Use separate namespaces or clusters for live Kubernetes validation.

## Required Scope

- Define which AWS accounts own CI, GitOps, clusters, logs, DNS, images,
  secrets, and data.
- Design cross-account IAM roles for CI, GitOps, platform operators, and
  workloads.
- Use EKS access entries or documented mappings for cluster access in each
  account.
- Allow clusters in dev, stage, and prod to pull approved images from ECR.
- Restrict prod deployment permissions separately from dev and stage.
- Design Route 53 hosted zone delegation or cross-account DNS updates.
- Design cross-account secret access or per-account secret replication.
- Define KMS key ownership and key policies for images, secrets, logs, and
  backup data.
- Centralize audit evidence through CloudTrail, log archive, or documented
  export commands.
- Show how a compromised dev principal is prevented from changing prod.

## AWS Touchpoints

- AWS Organizations or documented account structure.
- Cross-account IAM trust policies.
- IAM Identity Center permission sets or equivalent operator roles.
- EKS access entries for each environment cluster.
- ECR repository policies for cross-account pulls.
- Route 53 hosted zones, delegation, or ExternalDNS role assumption.
- KMS key policies and grants.
- Secrets Manager or SSM Parameter Store per environment.
- CloudTrail organization trail or account-level trails.
- Optional AWS RAM, Transit Gateway, VPC sharing, or peering plan.

## Kubernetes Requirements

- Environment-specific namespaces or clusters.
- RBAC that separates app teams, platform operators, and read-only auditors.
- Argo CD projects or instances separated by environment.
- NetworkPolicy and resource quotas per environment.
- Admission policies that are stricter in prod than dev.
- Evidence that prod cannot be modified with dev credentials.

## Deliverables

- Multi-account architecture diagram.
- Account responsibility matrix.
- IAM role, policy, and trust policy JSON for every cross-account path.
- ECR repository policy for cross-account image pull.
- Route 53 and DNS ownership plan.
- Secrets and KMS ownership plan.
- GitOps environment promotion plan.
- Audit evidence plan for CloudTrail, Kubernetes events, and Argo CD history.
- Attack-path notes for dev-to-prod isolation.

## Acceptance Criteria

- Dev, stage, and prod have clearly separated AWS identities and Kubernetes
  access paths.
- CI can publish artifacts without gaining direct prod cluster admin access.
- GitOps can deploy to the intended environment and cannot deploy outside its
  trust boundary.
- Production image pulls work through an explicit ECR policy or replication
  plan.
- Prod DNS and secrets cannot be modified by dev-only principals.
- Audit evidence can answer who changed what, when, and from which account.

## Suggested Work Breakdown

1. Draw the target account and cluster model.
2. Define human, CI, GitOps, and workload principals.
3. Write cross-account IAM trust policies.
4. Design image, DNS, secret, and KMS ownership.
5. Configure or model environment-specific GitOps access.
6. Validate allowed and denied account paths.
7. Write the platform handoff and risk register.

## Review Prompts

1. Which account owns the final production deployment decision?
2. What prevents a dev cluster role from assuming a prod role?
3. How does a prod cluster pull an image built in the tooling account?
4. Who can update production DNS records?
5. Which logs prove a cross-account role was assumed?
