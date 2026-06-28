# Platform Extensions And Operators Capstone

Capstone Level: 5 of 5

## Problem Statement

The platform team wants to offer higher-level self-service objects instead of
asking application teams to wire every Kubernetes object by hand. Your team must
design a small platform extension and prove that it behaves safely under normal
and failure conditions.

## Estimated Effort

10 to 16 hours. This can be implemented with a lightweight controller, an
existing operator, or a detailed design plus a mocked reconciliation workflow.

## Correlated Kubernetes Topics

- CRDs, custom resources, schemas, and validation.
- Controller reconciliation loops.
- OwnerReferences, finalizers, and garbage collection.
- Status subresources and conditions.
- Admission webhooks and policy.
- RBAC for controllers and custom resources.
- GitOps delivery for CRDs and controllers.
- Observability and troubleshooting for controllers.

## Required Scope

- Define a custom resource such as `MessageBoardEnvironment`,
  `TenantNamespace`, or `AppRelease`.
- Specify the resources the controller should create or manage.
- Add OpenAPI validation for required fields.
- Define status conditions that explain readiness and failures.
- Use OwnerReferences for managed child resources where appropriate.
- Use a finalizer for cleanup that must happen before deletion.
- Create RBAC for users and for the controller.
- Deploy the CRD and controller through GitOps or a documented release plan.
- Simulate a reconciliation failure and show how status helps troubleshoot.
- Document upgrade and deletion safety.

## AWS Touchpoints

- Optional IAM role for a controller that creates AWS-integrated resources.
- Optional ExternalDNS, cert-manager, External Secrets Operator, or AWS Load
  Balancer Controller as examples of production operators.
- CloudTrail or controller logs when AWS APIs are called.

## Deliverables

- CRD manifest with schema.
- Example custom resources for dev and prod.
- Controller behavior design or implementation.
- RBAC manifests for users and controller.
- Status and failure examples.
- GitOps deployment order for CRD, controller, and custom resources.
- Deletion and upgrade runbook.

## Acceptance Criteria

- The custom resource expresses a useful platform abstraction.
- Invalid custom resources are rejected or clearly flagged.
- Managed resources can be traced back to the owning custom resource.
- Status conditions explain whether reconciliation succeeded.
- Deletion does not leave unmanaged resources behind without documentation.
- Students can explain why operators need carefully scoped RBAC.

## Review Prompts

1. What problem does the custom resource solve for application teams?
2. Which fields must be validated before the controller acts?
3. What should happen if reconciliation partially succeeds?
4. Why are finalizers powerful and risky?
5. How would you roll out a breaking CRD version change?
