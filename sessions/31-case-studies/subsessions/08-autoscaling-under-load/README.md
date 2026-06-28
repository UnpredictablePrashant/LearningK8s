# Case Study 08: Autoscaling Under Load

## Scenario

Traffic increases and the application must scale before users feel pain. The
team has an HPA configured, but they need to prove that metrics are available,
load causes scale-out, the Deployment creates more Pods, and scale-down is
controlled after load stops.

This case study uses the Kubernetes HPA example image so students can generate
CPU load repeatably without depending on the larger training app.

## Target Outcome

The team can:

- Deploy a CPU-load target with resource requests.
- Create an HPA using `autoscaling/v2`.
- Generate traffic from inside the cluster.
- Watch HPA scale the Deployment up.
- Stop load and observe scale-down behavior.
- Troubleshoot common HPA failures.

The team should not:

- Configure HPA without CPU or memory requests.
- Expect HPA to work without Metrics Server or another metrics provider.
- Set `maxReplicas` without thinking about cost and downstream capacity.
- Assume Pod scaling solves node capacity problems automatically.

## Request Flow

```text
Load generator sends requests
  -> target Pods use more CPU
    -> Metrics Server reports Pod CPU usage
      -> HPA compares current utilization to target
        -> HPA updates Deployment replicas
          -> Deployment creates more Pods
            -> scheduler places Pods if nodes have capacity
```

## Objects Created

```text
Namespace: case-autoscaling
Deployment: scale-demo
Service: scale-demo
HorizontalPodAutoscaler: scale-demo
Deployment: load-generator
```

## Prerequisites

You need:

- A working Kubernetes cluster.
- Metrics Server installed and reporting metrics.
- Enough node capacity for several small Pods.

Check Metrics Server:

```bash
kubectl top nodes
kubectl top pods -A
```

If `kubectl top` does not work, HPA cannot make CPU or memory scaling decisions
from resource metrics.

## Step 1: Deploy The Target And HPA

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/08-autoscaling-under-load
bash scripts/01-deploy-autoscaling-target.sh
```

Check:

```bash
kubectl get deployment scale-demo -n case-autoscaling
kubectl get hpa scale-demo -n case-autoscaling
kubectl describe hpa scale-demo -n case-autoscaling
```

## Step 2: Start Load

Run:

```bash
bash scripts/02-start-load-and-watch.sh
```

In another terminal, watch:

```bash
kubectl get hpa scale-demo -n case-autoscaling -w
kubectl get deployment scale-demo -n case-autoscaling -w
```

Expected behavior:

```text
CPU rises above target
  -> HPA increases desired replicas
    -> Deployment creates more Pods
```

## Step 3: Inspect The Scaling Decision

Run:

```bash
kubectl describe hpa scale-demo -n case-autoscaling
kubectl top pods -n case-autoscaling
kubectl get events -n case-autoscaling --sort-by=.lastTimestamp
```

Important fields:

- `Metrics`: current CPU compared to target.
- `Min replicas` and `Max replicas`.
- `Conditions`.
- HPA events.

## Step 4: Stop Load

Run:

```bash
bash scripts/03-stop-load-and-observe.sh
```

Scale-down is intentionally slower than scale-up. Production systems usually
avoid aggressive scale-down because fast up/down movement can cause instability.

## Common HPA Problems

```text
current metrics show <unknown>
  -> Metrics Server is missing or cannot scrape kubelets

failed to get cpu utilization
  -> containers do not have CPU requests

HPA wants more replicas but Pods are Pending
  -> node capacity is insufficient; check Cluster Autoscaler, Karpenter, or EKS Auto Mode

Pods scale but app still fails
  -> downstream dependency, database, cache, or queue is the bottleneck

Scale-down is slow
  -> stabilization windows and HPA behavior are protecting the workload
```

## Production Guidance

- Set realistic CPU and memory requests before enabling HPA.
- Choose `minReplicas` based on availability, not only average traffic.
- Choose `maxReplicas` based on downstream capacity and cost.
- Pair HPA with node autoscaling for production clusters.
- Add alerts for HPA maxed out, Pending Pods, and unavailable replicas.
- Load test before depending on autoscaling in production.
- Watch database and queue capacity; autoscaling web Pods can overload
  downstream systems.

## Cleanup

```bash
bash scripts/04-cleanup-autoscaling-case.sh
```

## References

- Horizontal Pod Autoscaling: `https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/`
- HPA algorithm details: `https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details`
- Resource management for Pods: `https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/`
- Metrics Server: `https://github.com/kubernetes-sigs/metrics-server`
