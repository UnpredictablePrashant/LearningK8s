# Storage, State, And Data Protection Capstone

Capstone Level: 3 of 5

## Problem Statement

The message board cannot be treated as production while its data story is
unclear. Your team must make stateful storage explicit, protect data from common
failures, and prove restore steps before anyone trusts the app with real data.

## Estimated Effort

8 to 14 hours, depending on whether the team uses a local database, EBS-backed
storage, or an external managed database.

## Correlated Kubernetes Topics

- PersistentVolumes, PersistentVolumeClaims, and StorageClasses.
- StatefulSet identity, stable network names, and ordered startup.
- Dynamic provisioning through the Amazon EBS CSI driver.
- ConfigMaps and Secrets for database configuration.
- Resource requests, node placement, and storage zone constraints.
- Backup and restore with Velero or database-native tools.
- Secret rotation and application restart behavior.
- NetworkPolicy around database access.

## Required Scope

- Choose a database pattern: in-cluster PostgreSQL, managed database, or both.
- Use a PVC and StorageClass for in-cluster state.
- Document reclaim policy, expansion, encryption, and availability-zone limits.
- Restrict database access to only the app tier that needs it.
- Add backup for Kubernetes resources and database data.
- Restore into a separate namespace or cluster target.
- Rotate database credentials and show how the app receives the update.
- Simulate a PVC, Pod, or database failure and record recovery behavior.
- Document when in-cluster storage is acceptable and when managed storage is
  better.

## AWS Touchpoints

- Amazon EBS CSI driver and gp3 StorageClass.
- EBS volume encryption and KMS key choice.
- S3 backup bucket with versioning and lifecycle policy.
- Optional AWS Backup or RDS migration plan.
- IAM permissions for backup and restore tooling.

## Deliverables

- Storage architecture decision record.
- Manifests for StorageClass, PVC, StatefulSet or database Deployment, Services,
  and access policy.
- Backup and restore runbook with commands.
- Secret rotation procedure.
- Evidence from PVC binding, volume attachment, backup listing, and restore
  validation.
- Risk register for data loss, corruption, and zone failure.

## Acceptance Criteria

- The database uses persistent storage, not only container filesystem state.
- Backup artifacts can be listed from the expected backup location.
- Restore succeeds into an isolated target.
- Only intended Pods can connect to the database Service.
- Credential rotation has a documented application impact.
- Students can explain how storage decisions affect scheduling and recovery.

## Review Prompts

1. What happens to the data if the database Pod is deleted?
2. Which zone contains the volume, and why does that matter?
3. What is the difference between restoring Kubernetes objects and restoring
   database data?
4. How would you prove the restored database is correct?
5. What would make you move this database outside the cluster?
