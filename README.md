# Kubernetes Training Notes

This repository contains Kubernetes examples for Batch 16A, including simple root
manifests, a Flask/PostgreSQL learning app under `app/`, and the ordered course
labs under `sessions/`.

## Current EKS Version

As of 2026-06-13, the latest Amazon EKS Kubernetes version in standard support is
`1.36`.

Reference:

```text
https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
```

Before creating a cluster in the future, check the versions currently available
in your AWS account and region:

```bash
aws eks describe-cluster-versions --region us-east-2
```

## Prerequisites

Install and configure these tools before creating the cluster:

- AWS CLI v2
- `eksctl`
- `kubectl`
- An AWS IAM user or role with permissions to create EKS, EC2, VPC, IAM, and
  load balancer resources

Confirm AWS access:

```bash
aws sts get-caller-identity
```

## Create The EKS Cluster

The original notes used the cluster name `demo-batch16a` in `us-east-2`. This
README keeps the same values and adds the latest EKS version.

```bash
export CLUSTER_NAME=demo-batch16a
export AWS_REGION=us-east-2
export EKS_VERSION=1.36

eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --version "$EKS_VERSION" \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 3
```

This creates:

- An EKS control plane running Kubernetes `1.36`
- A managed node group named `standard-workers`
- Two `t3.medium` worker nodes, autoscaling between two and three nodes
- AWS networking resources required by the cluster

## Configure kubectl

```bash
aws eks --region "$AWS_REGION" update-kubeconfig --name "$CLUSTER_NAME"
```

Verify access:

```bash
kubectl version
kubectl get nodes
kubectl get namespaces
```

## Deploy The Root Nginx Example

From the repository root:

```bash
kubectl apply -f namespace-pk.yml
kubectl apply -f deployment-pk.yml
kubectl apply -f service-pk.yml
```

Check the workload:

```bash
kubectl get all -n pk
kubectl get service nginx-service -n pk
```

The `nginx-service` is a `LoadBalancer` service. On EKS, AWS provisions an
external load balancer for it. Wait until the `EXTERNAL-IP` or hostname appears,
then open it in a browser.

Cleanup the root example:

```bash
kubectl delete -f service-pk.yml --ignore-not-found
kubectl delete -f deployment-pk.yml --ignore-not-found
kubectl delete -f namespace-pk.yml --ignore-not-found
```

## Run The Training Sessions

Start with the roadmap:

```text
sessions/00-prerequisites-and-roadmap/README.md
```

The repository is now organized as a 30-session Kubernetes path plus a
scenario-driven case study section. Session 00 is the prerequisite and roadmap
entry point; Sessions 01-30 are the teaching flow, and Session 31 collects
real-world scenario labs.

| Session | Topic | Guide |
| --- | --- | --- |
| 00 | Prerequisites and roadmap | `sessions/00-prerequisites-and-roadmap/README.md` |
| 01 | Kubernetes architecture | `sessions/01-kubernetes-architecture/README.md` |
| 02 | Core Kubernetes objects | `sessions/02-core-k8s/README.md` |
| 03 | Configuration and Pod lifecycle | `sessions/03-configuration-and-pod-lifecycle/README.md` |
| 04 | Services and DNS | `sessions/04-services-and-dns/README.md` |
| 05 | Deployment operations | `sessions/05-deployment-operations/README.md` |
| 06 | Workload controllers, Jobs, CronJobs, DaemonSets | `sessions/06-workload-controllers/README.md` |
| 07 | Storage, PV, PVC, StatefulSet | `sessions/07-storage-pv-pvc-statefulset/README.md` |
| 08 | Ingress and edge routing | `sessions/08-ingress-edge-routing/README.md` |
| 09 | Gateway API and TLS | `sessions/09-gateway-api-and-tls/README.md` |
| 10 | Advanced scheduling | `sessions/10-advanced-scheduling/README.md` |
| 11 | Resource management and disruption safety | `sessions/11-resource-management/README.md` |
| 12 | Pod autoscaling | `sessions/12-pod-autoscaling/README.md` |
| 13 | Node autoscaling | `sessions/13-node-autoscaling/README.md` |
| 14 | RBAC and identity | `sessions/14-rbac-and-identity/README.md` |
| 15 | EKS IAM integration | `sessions/15-eks-iam-integration/README.md` |
| 16 | Security hardening | `sessions/16-security-hardening/README.md` |
| 17 | Secrets management | `sessions/17-secrets-management/README.md` |
| 18 | CNI, networking, eBPF | `sessions/18-cni-networking/README.md` |
| 19 | Observability | `sessions/19-observability/README.md` |
| 20 | Troubleshooting | `sessions/20-troubleshooting/README.md` |
| 21 | Helm | `sessions/21-helm/README.md` |
| 22 | Kustomize | `sessions/22-kustomize/README.md` |
| 23 | Argo CD and GitOps | `sessions/23-argocd-gitops/README.md` |
| 24 | Advanced Argo CD | `sessions/24-advanced-argocd/README.md` |
| 25 | Admission control and policy | `sessions/25-admission-control-and-policy/README.md` |
| 26 | CRDs, controllers, operators | `sessions/26-crds-controllers-operators/README.md` |
| 27 | Service mesh | `sessions/27-service-mesh/README.md` |
| 28 | Cluster operations | `sessions/28-cluster-operations/README.md` |
| 29 | Supply chain and CI/CD | `sessions/29-supply-chain-cicd/README.md` |
| 30 | Production capstone | `sessions/30-production-capstone/README.md` |
| 31 | Case studies and scenarios | `sessions/31-case-studies/README.md` |

Each session now has an ordered guide, sub-session structure, and app-based lab
examples where the topic can be demonstrated through the training application.
Some advanced examples require installing their controller or CRD first, and
cloud-specific examples include placeholder values that should be replaced for
your own AWS account, domain, registry, or Git repository.

Important provider prerequisites:

- Dynamic EBS StorageClass examples need the Amazon EBS CSI driver.
- Session 08 uses AWS Load Balancer Controller for the default ALB Ingress path.
- Session 12 needs Metrics Server for HPA and VPA resource metrics.
- Session 13 needs EKS Auto Mode, Karpenter, or Cluster Autoscaler for live node scaling.
- Session 23 needs outbound access to GitHub.

## Delete The EKS Cluster

Delete application resources first, then delete the cluster:

```bash
eksctl delete cluster --name "$CLUSTER_NAME" --region "$AWS_REGION"
```

If you did not keep the environment variables from earlier:

```bash
eksctl delete cluster --name demo-batch16a --region us-east-2
```

EKS clusters, worker nodes, EBS volumes, and load balancers can create AWS
charges while they exist. Delete the cluster when the lab is finished.
