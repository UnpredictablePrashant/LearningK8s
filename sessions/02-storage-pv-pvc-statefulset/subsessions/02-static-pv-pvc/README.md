# Sub-Session 02: Static PV And PVC

This sub-session creates storage manually using a static PersistentVolume and PersistentVolumeClaim.

## Why PersistentVolume Is Used

A PersistentVolume, or PV, represents storage available to the Kubernetes cluster.

In this learning example, the PV uses `hostPath`:

```text
/tmp/k8s-three-tier-postgres
```

That path exists on a Kubernetes node and is mounted into the PostgreSQL container later.

## Why PersistentVolumeClaim Is Used

A PersistentVolumeClaim, or PVC, is how an application requests storage.

PostgreSQL will mount the PVC. Flask will not mount it directly. Flask talks to PostgreSQL through a Service.

## Why Static Provisioning Is Used Here

Static provisioning makes the PV/PVC relationship visible:

```text
Admin creates PV -> App requests PVC -> Kubernetes binds PVC to PV
```

This is useful before teaching dynamic provisioning.

## Important Warning About hostPath

`hostPath` is not a normal production database storage backend. It ties data to one node path. If the Pod lands on another node, it may not see the same data.

Use it here only to teach the concept.

## Apply

Run sub-session 01 first.

From `sessions/02-storage-pv-pvc-statefulset`:

```bash
kubectl apply -f subsessions/02-static-pv-pvc/
```

## Check

```bash
kubectl get pv
kubectl get pvc -n app-storage
kubectl describe pvc postgres-data-static -n app-storage
```

Expected result:

```text
postgres-data-static -> Bound
postgres-static-hostpath-pv -> Bound
```

