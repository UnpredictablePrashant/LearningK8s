# Case Study 06: Rollout Failure And Rollback

## Scenario

A new application release is deployed during a production window. The rollout
does not complete because the new image tag is wrong. Some old Pods are still
serving traffic, but the Deployment is stuck and the team needs to diagnose the
failure and roll back safely.

This case study teaches the production rhythm: watch rollout status, inspect
ReplicaSets, read events, identify whether traffic is still safe, then roll
back to the last known-good revision.

## Target Outcome

The team can:

- Deploy a known-good release.
- Trigger a bad rollout with a missing image tag.
- Diagnose `ImagePullBackOff` and rollout progress failure.
- Roll back to the previous Deployment revision.
- Confirm the Deployment is healthy again.

The team should not:

- Delete the whole Namespace as the first response.
- Scale everything to zero during user traffic.
- Patch random fields without understanding the failed ReplicaSet.
- Ignore readiness and rollout status.

## Request Flow

```text
kubectl apply bad Deployment
  -> Deployment creates a new ReplicaSet
    -> new Pods try to pull a missing image
      -> Pods fail with ImagePullBackOff
        -> Deployment does not reach Available condition
          -> operator inspects events and rollout history
            -> kubectl rollout undo returns to previous ReplicaSet
```

## Objects Created

```text
Namespace: case-rollout
Deployment: rollout-demo
Service: rollout-demo
```

The Deployment uses a rolling update strategy with `maxUnavailable: 0`, so the
old healthy Pods remain available while the new image fails to start.

## Step 1: Deploy The Good Release

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/06-rollout-failure-and-rollback
bash scripts/01-deploy-good-release.sh
```

Check:

```bash
kubectl get deployment rollout-demo -n case-rollout
kubectl get pods -n case-rollout -o wide
kubectl rollout history deployment/rollout-demo -n case-rollout
```

## Step 2: Release A Bad Image

Run:

```bash
bash scripts/02-release-bad-image.sh
```

The script intentionally expects rollout failure. It prints useful evidence:

- Deployment status.
- ReplicaSets.
- Pods.
- Recent events.

Manual checks:

```bash
kubectl rollout status deployment/rollout-demo -n case-rollout --timeout=60s
kubectl describe deployment rollout-demo -n case-rollout
kubectl get replicasets -n case-rollout
kubectl describe pod -n case-rollout -l app.kubernetes.io/name=rollout-demo
kubectl get events -n case-rollout --sort-by=.lastTimestamp
```

Expected symptom:

```text
ImagePullBackOff
```

## Step 3: Roll Back

Run:

```bash
bash scripts/03-rollback-release.sh
```

Confirm:

```bash
kubectl rollout status deployment/rollout-demo -n case-rollout
kubectl get pods -n case-rollout
kubectl rollout history deployment/rollout-demo -n case-rollout
```

## How The Pieces Work Together

The Deployment answers this question:

```text
What version of the workload should exist?
```

The ReplicaSet answers this question:

```text
Which Pods belong to this specific Deployment revision?
```

The readiness probe answers this question:

```text
Should a Pod receive traffic through the Service?
```

The rollout command answers this question:

```text
Has the Deployment reached the desired state within its progress deadline?
```

Events answer this question:

```text
What did the kubelet, scheduler, or controller report while trying to run the
new Pods?
```

## Production Guidance

- Always watch `kubectl rollout status` or your CD system's equivalent.
- Keep `revisionHistoryLimit` high enough for emergency rollback.
- Use readiness probes that represent real service readiness.
- Prefer progressive delivery for high-risk services.
- Keep old Pods available during rollout with careful `maxUnavailable`.
- Record image tags, digests, commit SHAs, and release owner in annotations.
- Decide rollback criteria before the release starts.

## Cleanup

```bash
bash scripts/04-cleanup-rollout-case.sh
```

## References

- Kubernetes Deployments: `https://kubernetes.io/docs/concepts/workloads/controllers/deployment/`
- Kubernetes rolling updates: `https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/`
- `kubectl rollout`: `https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/`
