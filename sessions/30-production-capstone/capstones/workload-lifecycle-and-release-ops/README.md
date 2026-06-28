# Workload Lifecycle And Release Ops Capstone

Capstone Level: 1 of 5

## Problem Statement

The message board team has had repeated incidents during releases because Pods
start too early, shut down too abruptly, and rollbacks depend on manual
guesswork. Build a release-ready workload design that proves the app can start,
receive configuration, serve traffic, shut down, run background jobs, and roll
back predictably.

## Estimated Effort

6 to 10 hours, including implementation, broken-release testing, and the final
release runbook.

## Correlated Kubernetes Topics

- Pods, labels, selectors, and namespaces.
- ConfigMaps, Secrets, and environment variables.
- Init containers and sidecar containers.
- Readiness, liveness, and startup probes.
- Deployments, ReplicaSets, rollout history, and rollback.
- Jobs and CronJobs for operational tasks.
- Services and endpoint readiness.
- Resource requests and graceful termination.

## Required Scope

- Package frontend, app API, user API, and database manifests.
- Add probes that reflect real app behavior, not only container process state.
- Add init container logic for dependency checks or migration simulation.
- Add a sidecar or helper container for log shipping, config rendering, or
  another realistic support function.
- Add preStop and termination grace period settings for graceful shutdown.
- Add a Job for one-off data initialization or smoke testing.
- Add a CronJob for scheduled maintenance or synthetic health checks.
- Simulate at least two bad releases and show rollback commands.
- Document how ConfigMap or Secret changes are rolled out.

## Deliverables

- Kubernetes manifests or Helm/Kustomize package.
- Release checklist with pre-checks, rollout, verification, rollback, and
  cleanup.
- Evidence from `kubectl rollout status`, `kubectl rollout history`, logs,
  events, and endpoint readiness.
- Failure notes for the simulated bad releases.
- Short explanation of which lifecycle controls protect users.

## Acceptance Criteria

- A Pod does not receive traffic until it is actually ready.
- A broken image or broken config is detected during rollout.
- Rollback restores a previously working version.
- Graceful shutdown drains traffic before the container exits.
- A Job or CronJob runs successfully and has a clear operational purpose.
- Students can explain how probes, Services, and rollouts interact.

## Review Prompts

1. What is the difference between a running container and a ready Pod?
2. Which probe failure should restart the container, and which should only
   remove it from Service endpoints?
3. How does a ConfigMap change reach running Pods?
4. What evidence proves the rollback worked?
5. Which release step would you automate first?
