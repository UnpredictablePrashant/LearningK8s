# Session 31: Case Studies And Scenarios

This part of the course is for real-world situations where several Kubernetes
and cloud concepts meet in one request.

Instead of teaching one object at a time, each case study starts with a
scenario, explains the moving parts, then gives a runnable lab and validation
commands. Add new scenarios here when students ask, "How would we handle this
in a real project?"

## Case Study Format

Each case study should include:

- The situation the team is facing.
- The target outcome and what must be denied.
- The concepts involved.
- A request flow showing how the pieces work together.
- Step-by-step implementation.
- Manifests, IAM templates, scripts, or other lab code.
- Verification commands for allowed and denied behavior.
- Cleanup commands.

## Case Study Order

1. `subsessions/01-iam-user-namespace-access`: Give an AWS IAM user access to
   one Kubernetes Namespace on EKS by using an assumable IAM Role, an EKS access
   entry, and Kubernetes RBAC.
2. `subsessions/02-pod-access-to-s3`: Give a Pod least-privilege access to an
   S3 bucket prefix by using a Kubernetes ServiceAccount, an IAM Role, and EKS
   Pod Identity.
3. `subsessions/03-private-image-pull-from-ecr`: Run a workload from a private
   Amazon ECR image and troubleshoot `ImagePullBackOff` caused by registry or
   node-role permission problems.
4. `subsessions/04-secrets-manager-to-pod`: Sync a secret from AWS Secrets
   Manager into a Kubernetes Secret and consume it safely from a Pod.
5. `subsessions/05-internet-tls-with-alb`: Expose an application on the
   internet through an AWS ALB with ACM TLS termination.
6. `subsessions/06-rollout-failure-and-rollback`: Practice a production
   rollout that fails on a bad image and recover with `kubectl rollout undo`.
7. `subsessions/07-pod-cannot-connect-to-database`: Troubleshoot an app-to-DB
   connection failure caused by a Service with no endpoints.
8. `subsessions/08-autoscaling-under-load`: Run an HPA scaling drill with load,
   metrics checks, and scale-down behavior.
9. `subsessions/09-node-maintenance-and-disruption`: Practice node maintenance
   with replicas, topology spread, PodDisruptionBudget, guarded drain, and
   uncordon.
10. `subsessions/10-namespace-tenant-isolation`: Build a shared-cluster tenant
    boundary with Namespace, RBAC, ResourceQuota, LimitRange, and NetworkPolicy.
11. `subsessions/11-backup-and-restore-drill`: Run a Velero-style backup and
    restore drill for a stateful Namespace.
12. `subsessions/12-secret-rotation-and-restart`: Rotate a Kubernetes Secret
    and perform a controlled Deployment restart so Pods consume the new value.
13. `subsessions/13-cost-guardrails-and-runaway-workloads`: Protect a team
    Namespace from runaway workloads with quotas, defaults, labels, and HPA
    bounds.
14. `subsessions/14-break-glass-admin-access`: Create and revoke temporary EKS
    break-glass admin access through an assumable IAM Role, access entry, and
    ClusterRoleBinding.

## How To Use This Section

Run these labs after the identity sessions:

- Session 14: RBAC and Kubernetes identity.
- Session 15: EKS IAM integration.

The case studies assume the student already understands the basic nouns. The
value here is seeing how the nouns connect when a real access request arrives.

## Review Questions

1. Which parts of the solution live in AWS IAM?
2. Which parts of the solution live in EKS access management?
3. Which parts of the solution live in Kubernetes RBAC?
4. What command proves that access is limited to the intended Namespace?
5. What cleanup must happen when the person leaves the team?
