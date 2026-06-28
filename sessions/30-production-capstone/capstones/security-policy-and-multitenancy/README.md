# Security, Policy, And Multitenancy Capstone

Capstone Level: 4 of 5

## Problem Statement

Multiple teams now share the cluster, and every team wants fast delivery. Your
team must create boundaries that let teams work independently without allowing
one namespace, workload, or human identity to compromise another.

## Estimated Effort

10 to 14 hours. This capstone requires threat modeling, RBAC design, admission
policy, denied-access tests, and a clear ownership model.

## Correlated Kubernetes Topics

- Namespaces, labels, and ownership boundaries.
- ServiceAccounts, Roles, RoleBindings, ClusterRoles, and ClusterRoleBindings.
- Pod Security Standards and securityContext.
- NetworkPolicy and default deny.
- Admission control with Kyverno, Gatekeeper, or validating webhooks.
- Secrets management and external secret integration.
- EKS access entries, IAM roles, IRSA, or EKS Pod Identity.
- Audit logs and security review.

## Required Scope

- Create at least three namespaces: app, platform, and restricted sandbox.
- Define human access for developer, operator, and auditor personas.
- Define workload identities for app tiers and controllers.
- Apply Pod Security Standards or equivalent admission policy.
- Require labels, resource requests, and restricted container settings.
- Deny privileged containers, hostPath, hostNetwork, and mutable image tags.
- Add NetworkPolicy to isolate namespaces and app tiers.
- Externalize at least one secret and restrict who can read it.
- Prove denied behavior for unauthorized Kubernetes and AWS actions.
- Create an exception process for policy changes.

## AWS Touchpoints

- IAM roles for human and workload access.
- EKS access entries or documented cluster access mapping.
- EKS Pod Identity or IRSA for AWS permissions.
- Secrets Manager, SSM Parameter Store, or KMS for secret control.
- CloudTrail evidence for role assumption and secret access.

## Deliverables

- Threat model and tenant boundary diagram.
- RBAC manifests for personas and workloads.
- Admission policies and test manifests that pass and fail.
- NetworkPolicy manifests and connectivity tests.
- IAM and secret access policy JSON where AWS is involved.
- Security review checklist and exception process.
- Evidence of allowed and denied actions.

## Acceptance Criteria

- Developers can manage only their intended namespace.
- Auditors can read evidence without mutating workloads.
- Restricted namespace blocks privileged or unsafe Pods.
- Unauthorized Pods cannot read protected secrets or call protected AWS APIs.
- Policy violations produce clear feedback.
- Students can explain the difference between Kubernetes authorization and AWS
  authorization.

## Review Prompts

1. Which permissions are namespace-scoped and which are cluster-scoped?
2. What can a compromised ServiceAccount do?
3. Which policy stops an unsafe Pod before it is scheduled?
4. How do you grant a temporary exception without weakening the whole cluster?
5. Which evidence proves a denied action was actually denied?
