# Session 03: Configuration And Pod Lifecycle

This session expands the basic Pod examples with production Pod behavior.

## Sub-Session Order

1. `01-configmap-and-secret-review`: environment variables and mounted config.
2. `02-init-containers`: run setup before the main container starts.
3. `03-sidecar-containers`: helper containers in the same Pod.
4. `04-readiness-liveness-startup-probes`: health checks and traffic safety.
5. `05-lifecycle-hooks`: `postStart`, `preStop`, and graceful shutdown.
6. `06-pod-restart-policy`: Always, OnFailure, Never.
7. `07-pod-status-debugging`: phase, conditions, container states, events.

## Concepts

```text
Pod starts
  -> init containers run first
  -> app containers start
  -> startup probe protects slow startup
  -> readiness probe controls Service traffic
  -> liveness probe restarts broken containers
  -> preStop and grace period handle shutdown
```

## Existing Material To Reuse

- ConfigMap and Secret basics: `sessions/02-core-k8s/subsessions/02-configmap-secret`
- Standalone Pod basics: `sessions/02-core-k8s/subsessions/04-flask-pod`

## Lab Ideas

- Add readiness and liveness probes to the Flask Deployment.
- Add an init container that waits for PostgreSQL DNS.
- Add a sidecar that probes the app over localhost and writes to a shared
  `emptyDir` volume.
- Add a `preStop` hook and observe termination events.
- Break a liveness endpoint and watch Kubernetes restart the container.

## Review Questions

1. What is the difference between readiness and liveness?
2. Why are startup probes useful?
3. When should you use an init container?
4. What happens during graceful shutdown?
