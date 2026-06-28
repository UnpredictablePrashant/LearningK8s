# Session 00: Prerequisites And Roadmap

This is the entry point for the complete Kubernetes guide.

Use this session to prepare the environment, then follow Sessions 01-30 in
order. Session 31 adds scenario-driven case studies that combine multiple
topics after students have learned the building blocks. Existing hands-on labs
have been moved into the new sequence instead of being left in the older topic
order.

## Prerequisites

- Basic Linux command line comfort.
- Basic Docker image and container knowledge.
- AWS CLI v2 installed and configured.
- `eksctl` installed.
- `kubectl` installed.
- An AWS IAM user or role that can create EKS, EC2, VPC, IAM, EBS, and load
  balancer resources.

Confirm AWS access:

```bash
aws sts get-caller-identity
```

Confirm tools:

```bash
aws --version
eksctl version
kubectl version --client
docker version
```

## Recommended Course Order

| Session | Topic | Repository path | Status |
| --- | --- | --- | --- |
| 00 | Prerequisites and roadmap | `sessions/00-prerequisites-and-roadmap` | Ready |
| 01 | Kubernetes architecture | `sessions/01-kubernetes-architecture` | Detailed |
| 02 | Core Kubernetes objects | `sessions/02-core-k8s` | Ready |
| 03 | Configuration and Pod lifecycle | `sessions/03-configuration-and-pod-lifecycle` | Detailed |
| 04 | Services and DNS | `sessions/04-services-and-dns` | Detailed |
| 05 | Deployment operations | `sessions/05-deployment-operations` | Detailed |
| 06 | Workload controllers, DaemonSets, Jobs, CronJobs | `sessions/06-workload-controllers` | Ready |
| 07 | Storage, PV, PVC, StorageClass, StatefulSet | `sessions/07-storage-pv-pvc-statefulset` | Ready |
| 08 | Ingress and edge routing | `sessions/08-ingress-edge-routing` | Ready |
| 09 | Gateway API and TLS | `sessions/09-gateway-api-and-tls` | Detailed |
| 10 | Advanced scheduling | `sessions/10-advanced-scheduling` | Ready |
| 11 | Resource management and disruption safety | `sessions/11-resource-management` | Ready |
| 12 | Pod autoscaling with HPA and VPA | `sessions/12-pod-autoscaling` | Ready |
| 13 | Node autoscaling | `sessions/13-node-autoscaling` | Ready |
| 14 | RBAC and Kubernetes identity | `sessions/14-rbac-and-identity` | Ready |
| 15 | EKS IAM integration | `sessions/15-eks-iam-integration` | Detailed |
| 16 | Kubernetes security hardening | `sessions/16-security-hardening` | Detailed |
| 17 | Secrets management | `sessions/17-secrets-management` | Detailed |
| 18 | CNI, Kubernetes networking, and eBPF | `sessions/18-cni-networking` | Ready |
| 19 | Observability | `sessions/19-observability` | Detailed |
| 20 | Troubleshooting | `sessions/20-troubleshooting` | Detailed |
| 21 | Helm | `sessions/21-helm` | Detailed |
| 22 | Kustomize | `sessions/22-kustomize` | Detailed |
| 23 | Argo CD and GitOps | `sessions/23-argocd-gitops` | Ready |
| 24 | Advanced Argo CD | `sessions/24-advanced-argocd` | Detailed |
| 25 | Admission control and policy | `sessions/25-admission-control-and-policy` | Detailed |
| 26 | CRDs, controllers, and operators | `sessions/26-crds-controllers-operators` | Detailed |
| 27 | Service mesh | `sessions/27-service-mesh` | Detailed |
| 28 | Cluster operations | `sessions/28-cluster-operations` | Detailed |
| 29 | Supply chain and CI/CD | `sessions/29-supply-chain-cicd` | Detailed |
| 30 | Production capstone | `sessions/30-production-capstone` | Detailed |
| 31 | Case studies and scenarios | `sessions/31-case-studies` | Ready |

## Session Format

Each session README gives the main learning path, and the `subsessions/`
folders break that path into teachable blocks. Sub-session READMEs include the
goal, app-based lab command, checks, cleanup, and review prompts. When a topic
depends on an external controller, CRD, cloud integration, or real domain, the
example manifest stays close to the training app but uses placeholders that must
be replaced in a live cluster.

## Learning Flow

The order is intentional:

1. Learn the control plane and core objects.
2. Learn how Pods run, receive config, and expose traffic.
3. Learn workload controllers and persistent state.
4. Learn ingress, scheduling, resources, and autoscaling.
5. Learn identity, security, secrets, networking, and observability.
6. Learn packaging, GitOps, policy, operators, mesh, operations, and delivery.
7. Finish with a capstone that combines the production concerns.
8. Practice real-world access, operations, and troubleshooting scenarios through
   case studies.

## Review Questions

1. Why should architecture come before advanced troubleshooting?
2. Why should scheduling come before node autoscaling?
3. Why should RBAC come before controllers, operators, and Argo CD production use?
4. Which sessions need extra controllers or cloud account values before running
   the app-based examples?
