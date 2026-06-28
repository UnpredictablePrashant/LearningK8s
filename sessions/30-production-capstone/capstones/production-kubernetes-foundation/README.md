# Production Kubernetes Foundation Capstone

Capstone Level: 1 of 5

## Problem Statement

The message board application currently works as a learning app, but the
business wants it deployed as a production-style workload in one EKS cluster.
Your team must package the app, expose it safely, set operational guardrails,
and prove that routine failures do not take the service down.

## Estimated Effort

6 to 8 hours for a focused team, including design, implementation, validation,
runbook writing, and cleanup.

## Required Scope

- Create a production namespace such as `message-board-prod`.
- Package the frontend, user API, app API, PostgreSQL, ConfigMap, Secret, and
  Services with Helm or Kustomize.
- Expose the frontend through Ingress or Gateway API.
- Add TLS using cert-manager and a real or placeholder DNS name.
- Add resource requests, limits, LimitRange, ResourceQuota, and PDBs.
- Add readiness, liveness, and startup probes where needed.
- Add HPA for stateless tiers and document node autoscaling assumptions.
- Add topology spread or anti-affinity for stateless tiers.
- Add NetworkPolicy so only intended app-to-app traffic is allowed.
- Add basic metrics discovery and at least one alert for user impact.
- Run rollback, Pod restart, and node drain drills.

## AWS Touchpoints

- Use the AWS Load Balancer Controller or Gateway controller if the cluster has
  it installed.
- Use Route 53 and ACM or cert-manager DNS validation when a real domain is
  available.
- Use the Amazon EBS CSI driver for dynamic PostgreSQL storage.
- Document the AWS resources created by Kubernetes, such as load balancers,
  target groups, EBS volumes, and security groups.

## Kubernetes Requirements

- Namespace, Deployments, StatefulSet or database Deployment, Services, and
  ConfigMap or Secret.
- Ingress, Gateway API, or HTTPRoute with TLS.
- ServiceAccounts per application tier.
- ResourceQuota, LimitRange, PDB, HPA, and NetworkPolicy.
- ServiceMonitor or equivalent metrics discovery if Prometheus is available.
- PrometheusRule or equivalent alert definition.

## Deliverables

- Production package under a clear repository path.
- `README.md` with install, validate, rollback, and cleanup commands.
- Architecture diagram showing request flow and internal service flow.
- Evidence from `kubectl get`, `kubectl describe`, rollout, and failure drill
  commands.
- Production readiness notes covering risks, scaling assumptions, and database
  limitations.

## Acceptance Criteria

- The application is reachable through the configured edge route.
- A bad rollout can be detected and rolled back.
- Restarting one Pod does not create extended user-facing downtime.
- A node drain respects PDBs or documents why a tier cannot tolerate it yet.
- NetworkPolicy blocks unintended traffic while allowing the app to function.
- Alerts identify at least one user-impacting symptom.

## Suggested Work Breakdown

1. Package and deploy the base application.
2. Add edge routing, DNS, and TLS.
3. Add resource and scheduling controls.
4. Add NetworkPolicy and verify allowed and denied traffic.
5. Add metrics, alerting, and dashboards.
6. Run operational drills.
7. Write the final handoff.

## Review Prompts

1. Which resources are application-owned and which are platform-owned?
2. What would happen if the frontend image is broken?
3. Which traffic is denied by default?
4. Which tier is least production-ready and why?
5. What evidence proves the app survived the failure drills?
