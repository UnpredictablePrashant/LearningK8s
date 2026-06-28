# Case Study 10: Namespace Tenant Isolation

## Scenario

Multiple teams share one EKS cluster. Each team needs enough freedom to deploy
and debug its own workloads, but one team must not accidentally access another
team's namespace, consume unlimited cluster resources, or receive traffic from
unexpected namespaces.

This case study builds a practical namespace tenant boundary using Kubernetes
objects that production teams commonly combine.

## Target Outcome

Each tenant gets:

- A dedicated Namespace.
- A Kubernetes group bound to a namespaced Role.
- Default resource requests and limits through LimitRange.
- Aggregate resource caps through ResourceQuota.
- Default-deny ingress NetworkPolicy.
- Same-namespace ingress allow policy.
- A small demo Deployment and Service.

Each tenant should not:

- Get cluster-admin access.
- Read another tenant's Pods.
- Read Secrets by default.
- Create unlimited Pods or LoadBalancer Services.
- Receive arbitrary cross-namespace traffic.

## Request Flow

```text
Developer authenticates to Kubernetes
  -> EKS access entry or another auth layer adds a Kubernetes group
    -> RoleBinding grants that group a Role in one Namespace
      -> ResourceQuota and LimitRange control admitted resources
        -> NetworkPolicy controls Pod-to-Pod ingress
          -> workload runs inside a bounded tenant space
```

## Objects Created

```text
Namespace: case-tenant-a
Group: case-tenant-a-developers
RoleBinding: case-tenant-a-developers
ResourceQuota: tenant-quota
LimitRange: tenant-defaults
NetworkPolicy: default-deny-ingress
NetworkPolicy: allow-same-namespace-ingress
Deployment: tenant-web
Service: tenant-web

Namespace: case-tenant-b
Group: case-tenant-b-developers
same guardrail objects as team A
```

## Step 1: Apply Tenant Boundaries

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/10-namespace-tenant-isolation
bash scripts/01-apply-tenant-isolation.sh
```

Check:

```bash
kubectl get namespaces case-tenant-a case-tenant-b
kubectl get rolebinding,role,resourcequota,limitrange,networkpolicy -n case-tenant-a
kubectl get rolebinding,role,resourcequota,limitrange,networkpolicy -n case-tenant-b
```

## Step 2: Verify RBAC Boundaries

Run:

```bash
bash scripts/02-verify-rbac-boundaries.sh
```

Expected pattern:

```text
case-tenant-a-developers can list Pods in case-tenant-a
case-tenant-a-developers cannot list Pods in case-tenant-b
case-tenant-a-developers cannot read Secrets in case-tenant-a
case-tenant-a-developers cannot list Nodes
```

The same should be true in reverse for team B.

## Step 3: Demonstrate Quota Protection

Run:

```bash
bash scripts/03-demonstrate-quota.sh
```

The script applies a Deployment that asks for more Pods than the namespace quota
allows. Some Pods may be admitted, but the quota should prevent the full
replica count.

Inspect:

```bash
kubectl describe resourcequota tenant-quota -n case-tenant-a
kubectl get events -n case-tenant-a --sort-by=.lastTimestamp
```

## Step 4: Discuss NetworkPolicy

The manifests include:

```text
default-deny-ingress
allow-same-namespace-ingress
```

This means Pods in the same Namespace can talk to each other, but cross-tenant
traffic is denied when the CNI enforces Kubernetes NetworkPolicy.

Check whether your CNI enforces NetworkPolicy before depending on this in
production. Some CNIs require an additional policy engine.

## How The Pieces Work Together

RBAC answers:

```text
What can this authenticated user or group do against the Kubernetes API?
```

ResourceQuota answers:

```text
How much total resource can this Namespace consume?
```

LimitRange answers:

```text
What defaults and per-container limits should be applied during admission?
```

NetworkPolicy answers:

```text
Which Pod-to-Pod traffic is allowed at runtime?
```

Namespace answers:

```text
Where is this tenant boundary applied?
```

## Production Guidance

- Use groups, not individual user bindings, for tenant access.
- Keep cluster-scoped access separate and rare.
- Do not grant Secret read unless the workflow truly requires it.
- Use ResourceQuota and LimitRange before onboarding teams.
- Use NetworkPolicy with a CNI that enforces it.
- Add labels for owner, cost center, environment, and data classification.
- Standardize onboarding and offboarding with a repeatable template.

## Cleanup

```bash
bash scripts/04-cleanup-tenant-isolation-case.sh
```

## References

- Kubernetes RBAC: `https://kubernetes.io/docs/reference/access-authn-authz/rbac/`
- ResourceQuota: `https://kubernetes.io/docs/concepts/policy/resource-quotas/`
- LimitRange: `https://kubernetes.io/docs/concepts/policy/limit-range/`
- NetworkPolicy: `https://kubernetes.io/docs/concepts/services-networking/network-policies/`
