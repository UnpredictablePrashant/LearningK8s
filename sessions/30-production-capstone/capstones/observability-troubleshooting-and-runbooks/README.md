# Observability, Troubleshooting, And Runbooks Capstone

Capstone Level: 4 of 5

## Problem Statement

The app fails in ways that are hard to explain. Your team must build enough
observability to identify user impact, then create troubleshooting runbooks that
lead engineers from symptoms to root cause without guessing.

## Estimated Effort

8 to 12 hours, including dashboard setup, alert testing, failure injection, and
runbook writing.

## Correlated Kubernetes Topics

- Pod status, events, logs, and `kubectl describe`.
- Probes, rollout status, and deployment history.
- Metrics Server, Prometheus, Grafana, Alertmanager, and ServiceMonitor.
- Loki or another log aggregation path.
- OpenTelemetry traces where available.
- DNS, Service, NetworkPolicy, image pull, and storage troubleshooting.
- `kubectl debug` and ephemeral containers.
- Incident review and runbook design.

## Required Scope

- Define golden signals for the application.
- Add metrics scraping for at least one app tier.
- Add dashboards or query examples for traffic, errors, latency, saturation,
  Pod restarts, and resource pressure.
- Add at least three alerts: app unavailable, high error rate, and restart loop
  or resource pressure.
- Create failure scenarios for bad image, broken Service selector, blocked
  NetworkPolicy, failed readiness, and PVC issue.
- Use `kubectl debug` or a debug Pod in at least one investigation.
- Create runbooks for each failure scenario.
- Write a post-incident review for one simulated incident.

## AWS Touchpoints

- Optional CloudWatch Container Insights or log export.
- Load balancer health check evidence.
- CloudTrail or AWS controller logs for cloud-side failures.
- Optional SNS or ChatOps notification path.

## Deliverables

- Observability architecture diagram.
- ServiceMonitor, PrometheusRule, dashboard JSON, or equivalent query artifacts.
- Failure injection manifests or commands.
- Troubleshooting runbooks with decision steps and commands.
- Incident report with timeline, impact, root cause, and follow-up actions.
- Cleanup commands.

## Acceptance Criteria

- Alerts fire for controlled failures.
- Dashboards or queries show user-impacting symptoms.
- The team can diagnose at least three different failure classes.
- Runbooks include commands, expected output, and next action.
- Debug tooling does not require giving broad cluster-admin access to everyone.
- Students can connect symptoms across events, logs, metrics, and rollout state.

## Review Prompts

1. Which alert tells you users are impacted?
2. What is the first command for a Pod stuck in `ImagePullBackOff`?
3. How do you distinguish a Service selector issue from a NetworkPolicy issue?
4. Which logs belong to Kubernetes and which belong to AWS controllers?
5. What follow-up action should prevent the incident from repeating?
