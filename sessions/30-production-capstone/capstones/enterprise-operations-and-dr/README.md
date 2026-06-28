# Enterprise Operations And Disaster Recovery Capstone

Capstone Level: 5 of 5

## Problem Statement

The platform is now business-critical. Your team must operate it like a real
service by proving reliability, disaster recovery, incident response, upgrade
safety, auditability, and cost awareness across Kubernetes and AWS.

## Estimated Effort

16 to 24 hours. This is the final enterprise capstone and should include
planned drills, captured evidence, a readiness review, and a handoff suitable
for an operations team.

## Required Scope

- Define SLOs, SLIs, alert thresholds, and error-budget expectations.
- Build dashboards for availability, latency, errors, saturation, and resource
  usage.
- Create runbooks for user-impacting outage, failed rollout, bad certificate,
  database issue, node failure, and AWS access failure.
- Configure backup for Kubernetes resources and persistent data.
- Store backups in S3 with KMS encryption and restricted access.
- Prove restore into a separate namespace, cluster, account, or region.
- Design disaster recovery with documented RTO and RPO.
- Run at least three failure drills and capture results.
- Plan cluster upgrade and node replacement with rollback criteria.
- Review cost drivers and right-size at least one workload.
- Review audit evidence for IAM, Kubernetes RBAC, GitOps, and secret access.

## AWS Touchpoints

- S3 backup bucket with versioning and lifecycle policy.
- KMS key for backup and log encryption.
- Velero or equivalent backup tooling.
- Cross-account backup or restore role when an audit or backup account exists.
- Route 53 failover, weighted routing, or documented manual DNS failover.
- ECR image replication or documented image restore process.
- CloudWatch, Container Insights, OpenTelemetry Collector, or Prometheus remote
  write for metrics and logs.
- SNS, ChatOps, or ticketing integration for alerts.
- CloudTrail and IAM Access Analyzer for audit review.
- Optional AWS Backup, RDS, WAF, Shield, Security Hub, or GuardDuty integration.

## Kubernetes Requirements

- Backup and restore of namespaces, workloads, ConfigMaps, Secrets references,
  RBAC, and persistent volume data.
- PDBs, topology spread, HPA, and node autoscaling assumptions remain valid.
- Alert rules for app health and platform health.
- Runbooks stored with the application or platform repository.
- Upgrade plan for Kubernetes version, add-ons, and node groups.
- Incident timeline template and post-incident review template.

## Deliverables

- SLO document and alert matrix.
- Backup and restore manifests or command runbook.
- DR architecture diagram with RTO and RPO.
- Failure drill reports with timestamps, commands, expected results, actual
  results, and follow-up actions.
- Upgrade plan with pre-checks, execution steps, rollback steps, and validation.
- Cost review with recommended changes.
- Audit report covering IAM, RBAC, GitOps, secrets, and backup access.
- Final production readiness review.

## Acceptance Criteria

- A backup is created and listed from the expected S3 location.
- Restore succeeds into a separate recovery target.
- At least one alert fires during a controlled failure drill.
- The team can explain user impact using metrics, logs, events, and traces where
  available.
- The upgrade plan identifies compatibility checks and rollback criteria.
- The DR plan has explicit RTO and RPO values.
- Backup data, logs, and secrets are encrypted and access-controlled.
- Cost and capacity risks are documented with at least one concrete improvement.

## Suggested Work Breakdown

1. Define service objectives and incident categories.
2. Build dashboards and alerts.
3. Configure backup storage, IAM, KMS, and restore permissions.
4. Run backup and restore validation.
5. Execute failure drills.
6. Write upgrade, cost, and audit reviews.
7. Complete the production readiness handoff.

## Review Prompts

1. What is the maximum acceptable data loss?
2. Where would the team restore if the primary cluster is unavailable?
3. Which alert proves users are impacted?
4. Which evidence proves backups are encrypted and access-controlled?
5. What would stop the team from approving a cluster upgrade?
