# GitOps, Supply Chain, And OIDC Capstone

Capstone Level: 3 of 5

## Problem Statement

The team now needs a release system that does not depend on local laptops or
static AWS credentials. Your team must build images through CI, authenticate to
AWS through OIDC, publish to ECR, scan and sign artifacts, and promote changes
through GitOps into Kubernetes.

## Estimated Effort

10 to 16 hours. This capstone includes pipeline design, IAM OIDC trust,
artifact controls, Argo CD configuration, policy checks, and promotion testing.

## Required Scope

- Build container images for all application tiers from CI.
- Use GitHub Actions OIDC or an equivalent CI OIDC provider to assume an AWS IAM
  role.
- Push images to Amazon ECR without long-lived AWS keys.
- Use immutable tags or image digests for deployments.
- Run vulnerability scanning and fail or flag critical findings.
- Generate an SBOM for at least one image.
- Sign images with cosign or an equivalent signing workflow.
- Deploy with Argo CD from Git, not from direct `kubectl apply` in CI.
- Create separate dev, stage, and prod overlays or Helm values.
- Add a promotion flow where prod receives an already-built image digest.
- Add a policy check that rejects or flags unsigned images, mutable tags, or
  missing required labels.

## AWS Touchpoints

- IAM OIDC identity provider for the CI platform.
- IAM role trust policy limited by repository, branch, tag, or environment.
- ECR repositories with scan-on-push or enhanced scanning.
- ECR lifecycle rules for old images.
- Optional S3 bucket for SBOM and scan reports.
- Optional KMS key for signing material or artifact bucket encryption.

## Kubernetes Requirements

- Argo CD Application or ApplicationSet.
- AppProject boundaries for allowed repositories, namespaces, and clusters.
- Dev, stage, and prod overlays or Helm values.
- Admission policy with Kyverno, Gatekeeper, or another policy engine.
- ImagePullSecrets only if the cluster cannot use native ECR pull access.
- Rollback procedure through Git revert or previous image digest promotion.

## Deliverables

- CI workflow file.
- IAM OIDC provider and role trust policy.
- ECR repository configuration plan.
- Argo CD application manifests.
- Promotion documentation showing dev to stage to prod.
- SBOM, scan, and signing evidence.
- Policy evidence showing an unsafe deployment is rejected or flagged.
- Release runbook and rollback runbook.

## Acceptance Criteria

- CI can build and push to ECR without static AWS credentials.
- The role trust policy cannot be used by an unrelated repository.
- Argo CD deploys the approved image digest.
- A new image can be promoted without rebuilding it.
- A failed scan, unsigned image, or mutable tag creates a visible failure.
- Rollback is performed through GitOps, not manual cluster mutation.

## Suggested Work Breakdown

1. Design repository and environment layout.
2. Create ECR repositories and CI OIDC role.
3. Build and publish images from CI.
4. Add scanning, SBOM, and signing.
5. Connect Argo CD to the deployment repository.
6. Add policy checks.
7. Test promotion and rollback.
8. Write the delivery handoff.

## Review Prompts

1. What prevents a forked repository from assuming the AWS role?
2. Why should prod deploy an image digest instead of `latest`?
3. What happens when a scan finds a critical vulnerability?
4. Where is the boundary between CI and CD?
5. How can an auditor prove which commit produced the running image?
