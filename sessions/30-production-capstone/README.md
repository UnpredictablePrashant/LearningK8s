# Session 30: Production Capstones

This final session is a set of five substantial capstones. Each level is a
separate production-style problem, and each one should take meaningful design,
implementation, validation, and documentation time.

## One Big Problem Statement

Your company is moving the training message board application from a classroom
demo into a real EKS-based platform. The application starts as a single-cluster
Kubernetes workload, then grows into a secure AWS-integrated service, then into
a GitOps and supply-chain controlled delivery system, then into a multi-account
platform, and finally into an enterprise operations and disaster recovery
environment.

The platform team must prove that the application can be deployed, secured,
released, audited, recovered, and operated by different teams without relying on
manual cluster changes or long-lived credentials. Every level must produce both
working resources and a written handoff that a new engineer can follow.

## How The Levels Work

- Treat every level as its own capstone, not as a short exercise.
- Complete Level 1 before Level 2, and continue in order through Level 5.
- Use placeholders for account IDs, domains, ARNs, and repository names when
  writing reusable examples.
- When a real AWS account is available, include validation output from AWS CLI
  and `kubectl`.
- When a real AWS account is not available, submit the manifests, IAM policies,
  trust relationships, diagrams, and command plan that would be used.
- Do not mark a level complete until the team has a runbook, evidence, cleanup
  steps, and open risks.

## Progressive Capstones

| Capstone | Level | Estimated effort | Main focus |
| --- | --- | --- | --- |
| `capstones/production-kubernetes-foundation` | 1 of 5 | 6 to 8 hours | Production Kubernetes deployment, TLS, resources, rollout safety, NetworkPolicy, observability |
| `capstones/aws-integrated-secure-workloads` | 2 of 5 | 8 to 12 hours | EKS workload identity, IAM least privilege, Secrets Manager, KMS, S3, AWS controllers |
| `capstones/gitops-supply-chain-and-oidc` | 3 of 5 | 10 to 16 hours | GitHub Actions OIDC, ECR, image scanning, SBOM, signing, Argo CD promotion |
| `capstones/multi-account-platform` | 4 of 5 | 14 to 20 hours | Cross-account IAM, shared tooling, environment accounts, ECR pulls, Route 53, audit |
| `capstones/enterprise-operations-and-dr` | 5 of 5 | 16 to 24 hours | Multi-cluster operations, backup, restore, DR, SLOs, incident drills, upgrades, cost |

## Kubernetes Topic Correlation Capstones

Use these when you want a capstone around a specific Kubernetes domain instead
of the full Level 1-5 maturity path. Each topic capstone intentionally connects
multiple sessions so students must reason about how Kubernetes objects affect
each other in a real system.

| Topic capstone | Level | Estimated effort | Correlated topics |
| --- | --- | --- | --- |
| `capstones/workload-lifecycle-and-release-ops` | 1 of 5 | 6 to 10 hours | Pods, init containers, sidecars, probes, Deployments, Jobs, ConfigMaps, Secrets, rollout and rollback |
| `capstones/networking-dns-and-edge-routing` | 2 of 5 | 8 to 12 hours | Services, DNS, Ingress, Gateway API, TLS, NetworkPolicy, CNI, optional service mesh |
| `capstones/storage-state-and-data-protection` | 3 of 5 | 8 to 14 hours | PV, PVC, StorageClass, StatefulSet, EBS CSI, backup, restore, secret rotation |
| `capstones/scheduling-autoscaling-and-cost` | 3 of 5 | 8 to 12 hours | Node selectors, affinity, taints, topology spread, requests, limits, HPA, VPA, node autoscaling |
| `capstones/security-policy-and-multitenancy` | 4 of 5 | 10 to 14 hours | Namespaces, RBAC, ServiceAccounts, Pod Security, NetworkPolicy, admission policy, IAM, secrets |
| `capstones/observability-troubleshooting-and-runbooks` | 4 of 5 | 8 to 12 hours | Metrics, logs, events, alerts, probes, `kubectl debug`, rollout failures, runbooks |
| `capstones/platform-extensions-and-operators` | 5 of 5 | 10 to 16 hours | CRDs, controllers, operators, admission webhooks, RBAC, GitOps, status and finalizers |

## Required Evidence For Every Level

- Architecture diagram showing Kubernetes and AWS boundaries.
- Repository layout for manifests, Helm charts, Kustomize overlays, or platform
  IaC.
- Commands used to deploy, validate, roll back, and clean up.
- IAM policies and trust policies for all AWS access paths.
- Kubernetes RBAC, ServiceAccounts, and namespace boundaries.
- Security explanation for what is allowed and what is intentionally denied.
- Failure test or operational drill with expected and actual result.
- Final handoff document with remaining risks.

## Progressive Capstone Problem Statements

### Production Kubernetes Foundation Capstone

Level: 1 of 5

Package and run the message board as a production-style Kubernetes application
in one EKS cluster. The team must expose it safely, control resources, survive
routine disruption, and prove that basic operations are repeatable.

Start here:
`capstones/production-kubernetes-foundation/README.md`

### AWS Integrated Secure Workloads Capstone

Level: 2 of 5

Connect the Kubernetes application to AWS services without static credentials.
The team must use workload identity, least-privilege IAM, managed secrets,
encryption, and AWS controller permissions in a way that can be audited.

Start here:
`capstones/aws-integrated-secure-workloads/README.md`

### GitOps, Supply Chain, And OIDC Capstone

Level: 3 of 5

Build a delivery system where CI can build and publish images using OIDC,
GitOps deploys the approved version, and the cluster rejects or flags unsafe
artifacts. The team must separate build credentials from deploy credentials.

Start here:
`capstones/gitops-supply-chain-and-oidc/README.md`

### Multi-Account Platform Capstone

Level: 4 of 5

Split the platform across AWS accounts so development, staging, production,
tooling, and audit concerns are separated. The team must design cross-account
IAM, ECR access, GitOps deployment, DNS, secrets, and human access boundaries.

Start here:
`capstones/multi-account-platform/README.md`

### Enterprise Operations And Disaster Recovery Capstone

Level: 5 of 5

Operate the platform as if a real production service depends on it. The team
must prove backup and restore, incident response, upgrade safety, SLO-based
alerting, disaster recovery, auditability, and cost awareness.

Start here:
`capstones/enterprise-operations-and-dr/README.md`

## Existing Sub-Session Labs

The original sub-sessions remain as reusable implementation modules. Use them
inside the level capstones instead of treating them as the whole capstone.

1. `subsessions/01-package-the-app`: Create the production namespace and package the message board app stack.
2. `subsessions/02-deploy-through-gitops`: Register the capstone app with Argo CD.
3. `subsessions/03-add-tls-and-dns`: Expose the app through Gateway API with TLS.
4. `subsessions/04-add-resource-and-scheduling-controls`: Add replicas, resource requests, topology spread, and PDBs.
5. `subsessions/05-add-identity-security-and-secrets`: Add runtime identities and externalized secrets.
6. `subsessions/06-add-networkpolicy`: Restrict east-west traffic between the app services.
7. `subsessions/07-add-metrics-logs-and-alerts`: Add metrics discovery and a starter alert.
8. `subsessions/08-run-failure-drills`: Practice failure, rollback, drain, and recovery drills.
9. `subsessions/09-document-production-readiness`: Finish the production readiness review.

## Instructor Notes

- Level 1 can be done by one student or a small team.
- Levels 2 and 3 work best with students split into app, platform, and security
  roles.
- Levels 4 and 5 should be treated like design-and-build workshops. If real
  multi-account AWS access is not available, require complete IAM trust
  policies, diagrams, and validation commands.
- Require students to explain what a compromised Pod, CI workflow, or human IAM
  principal can and cannot do.
- The topic correlation capstones can be assigned to different teams in
  parallel, then combined into the Level 1 or Level 5 review.

## Final Review

1. Can the app survive a Pod restart, rollout, and node drain?
2. Can the team roll back a bad release through GitOps?
3. Can a Pod access only the AWS resources it is supposed to access?
4. Can CI publish images without long-lived AWS keys?
5. Can production be separated from development at the AWS and Kubernetes layer?
6. Can alerts explain user-impacting failure?
7. Can the team restore service from backup or a secondary environment?
8. Can a new engineer understand the runbook without asking the original team?
9. Can students explain how one Kubernetes decision affects another area, such
   as scheduling affecting cost, NetworkPolicy affecting troubleshooting, or
   probes affecting rollout safety?
