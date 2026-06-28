# Case Study 12: Secret Rotation And Restart

## Scenario

A database password, API token, or signing key must be rotated. The new value is
written to a Kubernetes Secret, but the application still uses the old value
because it consumed the Secret as environment variables when the container
started.

This is a production rotation problem. Updating a Kubernetes Secret changes the
object in the API server, but already-running containers do not automatically
receive updated environment variables. Those Pods need a controlled restart or
the application must read secrets from a mounted volume or external provider
with reload support.

## Target Outcome

The team can:

- Deploy an app that consumes a Secret.
- Prove the app is using secret version `v1`.
- Rotate the Secret to version `v2`.
- Prove existing Pods still show `v1`.
- Restart the Deployment safely.
- Prove new Pods consume `v2`.

The team should not:

- Print raw secret values during troubleshooting.
- Delete all Pods at once for critical services.
- Assume environment variables update when a Secret object changes.
- Rotate secrets without a rollback plan.

## Request Flow

```text
Secret app-runtime-secret has APP_SECRET_VERSION=v1
  -> Deployment starts Pods and injects env vars from the Secret
    -> Secret is updated to APP_SECRET_VERSION=v2
      -> existing container env vars still contain v1
        -> operator triggers rollout restart
          -> new Pods start and read v2
```

## Objects Created

```text
Namespace: case-secret-rotation
Secret: app-runtime-secret
Deployment: secret-aware-app
Service: secret-aware-app
PodDisruptionBudget: secret-aware-app
```

## Step 1: Deploy Secret Version v1

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/12-secret-rotation-and-restart
bash scripts/01-deploy-v1.sh
```

Check:

```bash
kubectl get deployment,pods,secret -n case-secret-rotation
bash scripts/02-check-pod-secret-version.sh
```

Expected output:

```text
APP_SECRET_VERSION=v1
```

## Step 2: Rotate The Secret To v2

Run:

```bash
bash scripts/03-rotate-secret-to-v2.sh
```

Check the running Pods again:

```bash
bash scripts/02-check-pod-secret-version.sh
```

Expected output is still:

```text
APP_SECRET_VERSION=v1
```

That is the point of the lab. The Secret object changed, but running container
environment variables did not.

## Step 3: Restart The Deployment Safely

Run:

```bash
bash scripts/04-rollout-restart-after-rotation.sh
```

Check again:

```bash
bash scripts/02-check-pod-secret-version.sh
```

Expected output:

```text
APP_SECRET_VERSION=v2
```

## How The Pieces Work Together

The Secret answers:

```text
What value should new Pods receive?
```

The Deployment answers:

```text
Which Pods should be replaced during a controlled rollout?
```

The PDB answers:

```text
How many Pods must stay available during voluntary disruption?
```

The rollout restart answers:

```text
How do we make new Pods read the rotated Secret without deleting everything by
hand?
```

## Production Guidance

- Prefer external secret stores for source-of-truth values.
- Avoid logging raw secret values. Log versions, checksums, or presence checks.
- Use at least two replicas and readiness probes for services that need
  zero-downtime rotation.
- Know whether the app reads secrets from env vars, mounted files, or a live
  provider SDK.
- If the app supports reload from mounted files, test that reload path.
- If the app uses env vars, include rollout restart in the rotation runbook.
- Rotate during a controlled window for high-risk credentials.
- Keep old credentials valid until all consumers have moved to the new value,
  then revoke the old value.

## Cleanup

```bash
bash scripts/05-cleanup-secret-rotation-case.sh
```

## References

- Kubernetes Secrets: `https://kubernetes.io/docs/concepts/configuration/secret/`
- Updating a Deployment: `https://kubernetes.io/docs/concepts/workloads/controllers/deployment/`
- PodDisruptionBudget: `https://kubernetes.io/docs/tasks/run-application/configure-pdb/`
