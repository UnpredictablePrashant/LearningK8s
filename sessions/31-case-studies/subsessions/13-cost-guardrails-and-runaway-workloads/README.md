# Case Study 13: Cost Guardrails And Runaway Workloads

## Scenario

A team accidentally deploys too many replicas or sets an autoscaler too high.
In a cloud Kubernetes cluster, that mistake can consume cluster capacity, force
node scale-out, and increase cost quickly.

This case study shows namespace-level cost and capacity guardrails: required
labels, default requests and limits, ResourceQuota, and bounded HPA settings.
Then it creates a runaway Deployment so students can see the quota protect the
cluster.

## Target Outcome

The team can:

- Create a cost-controlled Namespace.
- Apply default requests and limits.
- Cap aggregate Namespace resource usage.
- Deploy an app with owner and cost labels.
- Bound HPA with a sane `maxReplicas`.
- Demonstrate quota blocking a runaway workload.

The team should not:

- Allow Pods without requests in production.
- Let every Namespace create public load balancers.
- Use unlimited HPA `maxReplicas`.
- Ignore owner and cost-center labels.
- Treat node autoscaling as a substitute for workload governance.

## Request Flow

```text
Team deploys workload
  -> admission applies LimitRange defaults if resources are missing
    -> ResourceQuota checks aggregate namespace usage
      -> allowed Pods are created
        -> excess Pods are rejected with quota events
          -> platform team sees owner/cost labels and usage
```

## Objects Created

```text
Namespace: case-cost-guardrails
LimitRange: cost-defaults
ResourceQuota: cost-quota
Deployment: cost-aware-app
Service: cost-aware-app
HorizontalPodAutoscaler: cost-aware-app
Deployment: runaway-workers
```

## Step 1: Apply Guardrails And Normal App

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/13-cost-guardrails-and-runaway-workloads
bash scripts/01-apply-cost-guardrails.sh
```

Check:

```bash
kubectl describe limitrange cost-defaults -n case-cost-guardrails
kubectl describe resourcequota cost-quota -n case-cost-guardrails
kubectl get deployment,pods,hpa -n case-cost-guardrails
```

## Step 2: Show Owner And Cost Labels

Run:

```bash
bash scripts/02-report-tenant-cost-labels.sh
```

The report uses labels such as:

```text
owner=platform-training
cost-center=batch16a
environment=training
```

In production, these labels feed cost allocation, dashboards, and cleanup
automation.

## Step 3: Demonstrate Quota Protection

Run:

```bash
bash scripts/03-create-runaway-workload.sh
```

The Deployment asks for more replicas than the Namespace can admit. Inspect:

```bash
kubectl get deployment runaway-workers -n case-cost-guardrails
kubectl get pods -n case-cost-guardrails -l app.kubernetes.io/name=runaway-workers
kubectl describe resourcequota cost-quota -n case-cost-guardrails
kubectl get events -n case-cost-guardrails --sort-by=.lastTimestamp
```

Expected behavior:

```text
Some Pods may be created, but quota prevents the full runaway replica count.
```

## Step 4: Clean Up Runaway Load

Run:

```bash
bash scripts/04-delete-runaway-workload.sh
```

## How The Pieces Work Together

LimitRange answers:

```text
What resource defaults and per-container maximums apply inside the Namespace?
```

ResourceQuota answers:

```text
How much total CPU, memory, object count, and load balancer count can this
Namespace consume?
```

HPA answers:

```text
How far can this application scale automatically?
```

Labels answer:

```text
Who owns this workload, what environment is it in, and where should cost be
allocated?
```

## Production Guidance

- Apply guardrails before onboarding a team Namespace.
- Require owner, environment, and cost-center labels through policy.
- Use ResourceQuota to cap Pods, CPU, memory, PVCs, and LoadBalancer Services.
- Use LimitRange to prevent Pods with no requests from breaking scheduling and
  autoscaling behavior.
- Set HPA `maxReplicas` based on cost and downstream capacity.
- Alert on quota exhaustion, Pending Pods, and HPA maxed out.
- Review idle Services, unattached PVCs, and old preview namespaces regularly.

## Cleanup

```bash
bash scripts/05-cleanup-cost-guardrails-case.sh
```

## References

- ResourceQuota: `https://kubernetes.io/docs/concepts/policy/resource-quotas/`
- LimitRange: `https://kubernetes.io/docs/concepts/policy/limit-range/`
- HPA: `https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/`
- Recommended labels: `https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/`
