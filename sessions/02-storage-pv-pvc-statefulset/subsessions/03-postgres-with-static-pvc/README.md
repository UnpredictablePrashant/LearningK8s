# Sub-Session 03: PostgreSQL With Static PVC

This sub-session runs PostgreSQL using the PVC created in the previous step.

## Why PostgreSQL Mounts The PVC

PostgreSQL writes database files under:

```text
/var/lib/postgresql/data
```

The manifest mounts the PVC at that path. This moves the database files outside the container lifecycle.

## How Kubernetes Uses It

The Deployment references the PVC:

```yaml
volumes:
  - name: postgres-storage
    persistentVolumeClaim:
      claimName: postgres-data-static
```

The container mounts it:

```yaml
volumeMounts:
  - name: postgres-storage
    mountPath: /var/lib/postgresql/data
```

## Why Service Is Still Needed

The PVC solves storage. It does not solve networking.

Flask still needs a stable DNS name to reach PostgreSQL, so this sub-session also creates the `postgres` Service.

## Apply

Run sub-sessions 01 and 02 first.

From `sessions/02-storage-pv-pvc-statefulset`:

```bash
kubectl apply -f subsessions/03-postgres-with-static-pvc/
```

## Check

```bash
kubectl get deployment postgres -n app-storage
kubectl get pods -n app-storage -l app=postgres,storage-demo=static
kubectl get service postgres -n app-storage
kubectl get pvc -n app-storage
```

## Persistence Test

After Flask is deployed in the next sub-session, add messages through the UI. Then delete the PostgreSQL Pod:

```bash
kubectl delete pod -n app-storage -l app=postgres,storage-demo=static
kubectl get pods -n app-storage -w
```

When the new Pod becomes ready, the messages should still exist.

