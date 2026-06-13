# Sub-Session 06: PostgreSQL StatefulSet

This sub-session replaces the static PostgreSQL Deployment with a StatefulSet that creates its own PVC.

## Why StatefulSet Is Used

PostgreSQL is stateful because it stores database files. A StatefulSet is designed for workloads that need stable identity and stable storage.

For one PostgreSQL replica, the Pod name is stable:

```text
postgres-stateful-0
```

## Why volumeClaimTemplates Is Used

`volumeClaimTemplates` lets a StatefulSet create a PVC for each Pod.

The generated PVC name will be:

```text
postgres-data-postgres-stateful-0
```

That PVC uses:

```text
storageClassName: ebs-gp3
```

## How Kubernetes Uses It

The StatefulSet creates:

- A stable PostgreSQL Pod.
- A PVC from the template.
- A volume mount for PostgreSQL data.

The manifest also creates:

- `postgres-headless`: required by the StatefulSet for stable network identity.
- `postgres`: normal ClusterIP Service used by Flask.

## Before Applying

If the static PostgreSQL Deployment is running, remove it first:

```bash
kubectl delete -f subsessions/03-postgres-with-static-pvc/ --ignore-not-found
```

Apply the StorageClass sub-session first if the cluster does not already have `ebs-gp3`.

## Apply

From `sessions/02-storage-pv-pvc-statefulset`:

```bash
kubectl apply -f subsessions/06-postgres-statefulset/
```

## Check

```bash
kubectl get statefulset -n app-storage
kubectl get pods -n app-storage -l app=postgres,storage-demo=stateful
kubectl get pvc -n app-storage
kubectl get pv
```

## Persistence Test

Deploy Flask if it is not already running:

```bash
kubectl apply -f subsessions/04-flask-with-persistent-db/
```

Add messages through the UI. Then delete PostgreSQL:

```bash
kubectl delete pod postgres-stateful-0 -n app-storage
kubectl get pods -n app-storage -w
```

When PostgreSQL is ready again, refresh the app. The messages should still exist.

## Cleanup Note

StatefulSet PVCs are retained after the StatefulSet is deleted. Delete them explicitly when the lab is finished:

```bash
kubectl delete pvc -n app-storage -l app=postgres,storage-demo=stateful
```

