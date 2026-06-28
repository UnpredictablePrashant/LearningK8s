# Case Study 14: Break-Glass Admin Access

## Scenario

The normal platform access path is broken during an incident. The team needs a
temporary emergency path to the EKS cluster, but that path must be auditable,
time-bounded, and easy to revoke.

This case study creates a break-glass IAM Role, maps it into EKS with an access
entry, binds its Kubernetes group to `cluster-admin`, tests it, then removes it.
It is intentionally guarded because it grants powerful access.

## Target Outcome

The platform team can:

- Create a dedicated emergency IAM Role.
- Allow a specific IAM principal to assume that role.
- Map the role into Kubernetes through an EKS access entry.
- Bind the role's Kubernetes group to `cluster-admin`.
- Test access.
- Revoke the emergency path completely.

The platform team should not:

- Leave permanent emergency admin access active.
- Share static admin kubeconfigs.
- Reuse normal application roles for human admin access.
- Skip audit notes, ticket IDs, or incident IDs.
- Forget to remove the ClusterRoleBinding and access entry.

## Important Concept

Break-glass access should be exceptional, not the normal operating path.

```text
Normal access
  -> least privilege, team-scoped, routine

Break-glass access
  -> emergency only, highly privileged, audited, short lived, revoked quickly
```

On EKS, the clean production pattern is:

```text
IAM principal assumes a break-glass IAM Role
  -> EKS access entry maps the role to a Kubernetes group
    -> ClusterRoleBinding grants that group cluster-admin
      -> cleanup removes both AWS and Kubernetes access
```

## Objects Created

AWS objects:

```text
IAM Role: EksBreakGlassAdminRole
  trust policy:
    allows one configured principal to assume the role
  max session duration:
    3600 seconds
  inline policy:
    allows eks:DescribeCluster for this cluster

EKS access entry:
  principal: arn:aws:iam::<account-id>:role/EksBreakGlassAdminRole
  Kubernetes group: case-break-glass-admins
```

Kubernetes objects:

```text
ClusterRoleBinding: case-break-glass-admins-cluster-admin
  subject group: case-break-glass-admins
  roleRef: cluster-admin
```

## Prerequisites

You need:

- AWS CLI v2.
- `kubectl`.
- An EKS cluster with access entries enabled.
- Admin permission to create IAM roles and EKS access entries.
- Cluster permission to create ClusterRoleBindings.
- The IAM ARN of the person or role allowed to assume break-glass access.

Check access entry mode:

```bash
aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query 'cluster.accessConfig.authenticationMode' \
  --output text
```

The mode must be `API` or `API_AND_CONFIG_MAP`.

## Set Lab Variables

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/14-break-glass-admin-access
```

Set values:

```bash
export CLUSTER_NAME=demo-batch16a
export AWS_REGION=us-east-2
export BREAK_GLASS_PRINCIPAL_ARN=arn:aws:iam::111122223333:user/platform-admin

export ROLE_NAME=EksBreakGlassAdminRole
export K8S_GROUP=case-break-glass-admins
export INCIDENT_ID=INC-0001
```

## Step 1: Create Break-Glass Access

Run:

```bash
export CONFIRM_BREAK_GLASS=true
bash scripts/01-create-break-glass-access.sh
```

This creates:

- IAM Role.
- `eks:DescribeCluster` policy for kubeconfig discovery.
- EKS access entry.
- ClusterRoleBinding to `cluster-admin`.

## Step 2: Test The Access

Run as the principal that is trusted by the break-glass role:

```bash
bash scripts/02-test-break-glass-access.sh
```

Expected output:

```text
kubectl auth can-i '*' '*'
  -> yes
```

The script uses temporary STS credentials from `sts:AssumeRole`.

## Step 3: Revoke Access

Run as the platform admin:

```bash
export CONFIRM_REVOKE_BREAK_GLASS=true
bash scripts/03-revoke-break-glass-access.sh
```

Then verify:

```bash
aws eks describe-access-entry \
  --cluster-name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --principal-arn "arn:aws:iam::<account-id>:role/$ROLE_NAME"

kubectl get clusterrolebinding case-break-glass-admins-cluster-admin
```

Both should be gone.

## Production Guidance

- Require MFA or IAM Identity Center controls before a user can assume the
  break-glass role.
- Keep max session duration short.
- Require an incident ID, ticket, and approver.
- Alert on `sts:AssumeRole` for the break-glass role.
- Review CloudTrail and Kubernetes audit logs after use.
- Revoke the access entry and ClusterRoleBinding as part of incident closure.
- Store the runbook somewhere available even when GitOps or SSO is impaired.

## Cleanup

The revoke script is the cleanup:

```bash
export CONFIRM_REVOKE_BREAK_GLASS=true
bash scripts/03-revoke-break-glass-access.sh
```

## References

- EKS access entries: `https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html`
- IAM roles: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html`
- IAM temporary credentials: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html`
- Kubernetes RBAC: `https://kubernetes.io/docs/reference/access-authn-authz/rbac/`
