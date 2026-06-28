# Case Study 09: Node Maintenance And Disruption

## Scenario

A worker node needs maintenance. The platform team must move Pods away from the
node without causing avoidable application downtime. This is the normal
production path for node upgrades, AMI replacement, kernel patching, or
suspected node problems.

This case study deploys a small app with replicas, topology spread, and a
PodDisruptionBudget. Then it walks through choosing a node, draining it
carefully, watching Pods reschedule, and uncordoning the node.

## Target Outcome

The team can:

- Deploy a disruption-ready workload.
- Check replica placement across nodes.
- Confirm the PodDisruptionBudget.
- Cordon and drain one node intentionally.
- Confirm Pods reschedule and the app stays available.
- Uncordon the node after maintenance.

The team should not:

- Drain production nodes without knowing which workloads are affected.
- Ignore PodDisruptionBudgets.
- Drain every node at once.
- Leave a node cordoned after maintenance.
- Use one replica for a production service that must survive node disruption.

## Request Flow

```text
Node is selected for maintenance
  -> operator checks Pods on that node
    -> operator checks PDB and replica health
      -> node is cordoned so no new Pods schedule there
        -> node is drained so evictable Pods move away
          -> Deployment creates replacement Pods on other nodes
            -> node is patched or inspected
              -> node is uncordoned when ready
```

## Objects Created

```text
Namespace: case-node-maintenance
Deployment: drain-safe-web
Service: drain-safe-web
PodDisruptionBudget: drain-safe-web
```

The Deployment uses:

- `replicas: 3`
- readiness and liveness probes
- topology spread across hostnames
- soft anti-affinity so Pods prefer different nodes

The PDB uses:

```text
minAvailable: 2
```

## Step 1: Deploy The Workload

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/09-node-maintenance-and-disruption
bash scripts/01-deploy-drain-safe-workload.sh
```

Check:

```bash
kubectl get pods -n case-node-maintenance -o wide
kubectl get pdb -n case-node-maintenance
kubectl describe pdb drain-safe-web -n case-node-maintenance
```

## Step 2: Choose A Candidate Node

Run:

```bash
bash scripts/02-choose-drain-node.sh
```

The script prints the node names that currently host the workload. Pick one and
export it:

```bash
export NODE_NAME=<node-name>
```

Before draining, inspect everything on that node:

```bash
kubectl get pods -A --field-selector spec.nodeName="$NODE_NAME" -o wide
```

## Step 3: Drain The Node Safely

The drain script refuses to run unless you explicitly confirm:

```bash
export CONFIRM_DRAIN=true
bash scripts/03-drain-node-safely.sh
```

Watch the workload:

```bash
kubectl get pods -n case-node-maintenance -o wide -w
```

Expected behavior:

```text
The selected node becomes SchedulingDisabled.
Evictable Pods leave the node.
Replacement Pods are created on other schedulable nodes.
At least 2 Pods should remain available because of the PDB.
```

## Step 4: Uncordon The Node

After maintenance:

```bash
bash scripts/04-uncordon-node.sh
```

Check:

```bash
kubectl get nodes
kubectl get pods -n case-node-maintenance -o wide
```

## Production Troubleshooting

If drain hangs, check:

```bash
kubectl get pdb -A
kubectl describe pdb drain-safe-web -n case-node-maintenance
kubectl get pods -A --field-selector spec.nodeName="$NODE_NAME"
kubectl describe node "$NODE_NAME"
```

Common causes:

```text
PDB blocks eviction
  -> too few healthy replicas are available

Pods are unmanaged
  -> drain needs --force, but production should investigate ownership first

Pods use local emptyDir data
  -> drain needs --delete-emptydir-data and the team must accept data loss

Replacement Pods are Pending
  -> other nodes do not have enough CPU, memory, taints, or topology capacity
```

## Production Guidance

- Use at least two replicas for services that must survive voluntary
  disruption.
- Use PDBs to tell Kubernetes how much disruption is acceptable.
- Use topology spread or anti-affinity for important services.
- Drain one node at a time unless the platform has proven larger disruption is
  safe.
- Always uncordon nodes after maintenance.
- Pair node maintenance with alerts for unavailable replicas and pending Pods.

## Cleanup

```bash
bash scripts/05-cleanup-node-maintenance-case.sh
```

## References

- Safely drain a node: `https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/`
- PodDisruptionBudget: `https://kubernetes.io/docs/tasks/run-application/configure-pdb/`
- Topology spread constraints: `https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/`
