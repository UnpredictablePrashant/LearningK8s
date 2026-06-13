# Sub-Session 05: StorageClass

This sub-session introduces dynamic storage provisioning with a StorageClass.

## Why StorageClass Is Used

Static PVs are useful for learning, but they do not scale well. In real clusters, users should be able to request storage and let Kubernetes create the backing disk automatically.

A StorageClass defines what kind of storage to create.

## How Kubernetes Uses It

With dynamic provisioning:

```text
PVC requests storage -> StorageClass calls CSI driver -> PV is created automatically
```

For EKS, this example uses the Amazon EBS CSI provisioner:

```text
ebs.csi.aws.com
```

## EKS Requirement

The Amazon EBS CSI driver must be installed in the cluster.

Check:

```bash
kubectl get csidriver
kubectl get storageclass
```

## Manifest

```text
01-storageclass-aws-ebs-gp3.yml
```

It creates a gp3 EBS StorageClass named:

```text
ebs-gp3
```

## Apply

From `sessions/02-storage-pv-pvc-statefulset`:

```bash
kubectl apply -f subsessions/05-storageclass/
```

## Check

```bash
kubectl get storageclass
kubectl describe storageclass ebs-gp3
```

The next sub-session uses this StorageClass in a StatefulSet `volumeClaimTemplates`.

