# Case Study 11: Backup And Restore Drill

## Scenario

A team accidentally deletes a namespace that contains a stateful application.
The platform team must restore Kubernetes objects and persistent data from a
backup, then prove the restored app still has its data.

This case study uses a Velero-style workflow because Velero is a common
production backup tool for Kubernetes clusters. The lab deploys a small
PVC-backed workload, creates a namespace backup, simulates loss by deleting the
namespace, restores from backup, and verifies the file on the restored volume.

## Target Outcome

The team can:

- Deploy a stateful workload with a PVC.
- Write a known marker file to the volume.
- Create a backup for one Namespace.
- Simulate namespace loss.
- Restore the Namespace.
- Verify the restored workload and data.

The team should not:

- Treat backup success as restore success.
- Delete production namespaces without a tested restore plan.
- Assume PVC data is protected unless volume snapshots or file-system backup
  are configured.
- Skip restore drills.

## Request Flow

```text
Stateful workload writes marker file to PVC
  -> Velero backup captures namespace objects and volume data
    -> namespace is deleted to simulate loss
      -> Velero restore recreates objects and volume data
        -> workload starts again
          -> verification reads marker file from restored volume
```

## Objects Created

```text
Namespace: case-backup-restore
PersistentVolumeClaim: backup-data
Deployment: backup-writer
```

The Pod writes:

```text
/data/restore-marker.txt
```

## Prerequisites

You need:

- `kubectl`.
- Velero CLI.
- Velero installed in the cluster.
- A configured backup storage location.
- Volume snapshot or file-system backup support if you want PVC data restored,
  not only Kubernetes object metadata.

Check Velero:

```bash
velero version
velero backup-location get
velero snapshot-location get
```

If Velero is not installed yet, install it according to your cloud and storage
backend. On EKS, production setups commonly use S3 for backup storage and EBS
CSI snapshots or Velero node-agent file-system backup for persistent data.

## Step 1: Deploy The Stateful Sample

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/11-backup-and-restore-drill
bash scripts/01-deploy-stateful-sample.sh
```

Check the marker file:

```bash
bash scripts/02-verify-marker-file.sh
```

## Step 2: Create A Backup

Run:

```bash
bash scripts/03-create-velero-backup.sh
```

The script prints the backup name. Save it:

```bash
export BACKUP_NAME=<printed-backup-name>
```

Inspect:

```bash
velero backup describe "$BACKUP_NAME" --details
```

## Step 3: Simulate Namespace Loss

Run:

```bash
export CONFIRM_DELETE_NAMESPACE=true
bash scripts/04-simulate-namespace-loss.sh
```

The confirmation variable is required because this intentionally deletes the
lab namespace.

## Step 4: Restore From Backup

Run:

```bash
bash scripts/05-restore-velero-backup.sh
```

The script waits for restore completion and verifies the marker file after the
Deployment comes back.

## Production Restore Checklist

For a real incident, capture:

```text
1. What was deleted or corrupted?
2. Which backup contains the last known-good state?
3. Does the restore target already contain conflicting objects?
4. Are PVCs restored from snapshots or file-system backup?
5. Are Secrets and external dependencies included?
6. Does the app pass functional checks after restore?
7. Did DNS, Ingress, certificates, and identities recover too?
```

## How The Pieces Work Together

Velero backup answers:

```text
Which Kubernetes objects and volume data were captured at a point in time?
```

Backup storage location answers:

```text
Where is backup metadata stored?
```

Snapshot location or file-system backup answers:

```text
How is persistent volume data protected?
```

Restore answers:

```text
Which backup should be replayed into the cluster?
```

Verification answers:

```text
Did the restored workload actually work, and did its data return?
```

## Production Guidance

- Run restore drills on a schedule.
- Tag backup storage and snapshots for ownership and retention.
- Test both object restore and volume data restore.
- Keep backups in a separate failure domain from the cluster.
- Protect backup buckets with versioning, encryption, and restricted access.
- Document RPO and RTO for each application.
- Remember that external systems such as RDS, S3, queues, and DNS may need
  separate backup and restore plans.

## Cleanup

```bash
bash scripts/06-cleanup-backup-restore-case.sh
```

The cleanup removes the lab namespace. It does not delete Velero backups by
default. To delete the backup too:

```bash
export DELETE_VELERO_BACKUP=true
bash scripts/06-cleanup-backup-restore-case.sh
```

## References

- Velero documentation: `https://velero.io/docs/`
- Velero backup reference: `https://velero.io/docs/main/backup-reference/`
- Velero restore reference: `https://velero.io/docs/main/restore-reference/`
- Kubernetes persistent volumes: `https://kubernetes.io/docs/concepts/storage/persistent-volumes/`
