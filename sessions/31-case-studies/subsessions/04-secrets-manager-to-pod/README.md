# Case Study 04: Secrets Manager To Pod

## Scenario

An application needs a database username and password. The security team does
not want the secret committed to Git or typed into a Kubernetes manifest.

In production, the external secret store should be the source of truth, and the
Pod should consume a normal Kubernetes Secret created by a controller. This case
study uses AWS Secrets Manager, External Secrets Operator, and EKS Pod Identity.

## Target Outcome

The platform can:

- Store the application secret in AWS Secrets Manager.
- Give External Secrets Operator least-privilege access to that one secret.
- Sync the external secret into a Kubernetes Secret.
- Let the application consume the synced Kubernetes Secret.

The platform should not:

- Store plaintext secret values in Git.
- Put AWS user access keys in the application Pod.
- Give every workload permission to call Secrets Manager.
- Print secret values in normal application logs.

## Important Concept

There are two identities in this pattern:

```text
External Secrets Operator controller identity
  -> has AWS permission to read from Secrets Manager

Application Pod identity
  -> reads a Kubernetes Secret mounted or injected by Kubernetes
  -> does not need AWS Secrets Manager permissions
```

This separation is important. The application gets the value it needs, while
the AWS read permission stays with the sync controller.

## Request Flow

```text
Secret value exists in AWS Secrets Manager
  -> External Secrets Operator runs with a Pod Identity IAM Role
    -> controller reads the selected secret from Secrets Manager
      -> controller writes a Kubernetes Secret in the app Namespace
        -> app Pod consumes the Kubernetes Secret as environment variables
```

## Objects Created

AWS objects:

```text
Secrets Manager secret: <SECRET_NAME>

IAM Role: EksExternalSecretsCaseStudyRole
  trust policy:
    trusts pods.eks.amazonaws.com for the external-secrets ServiceAccount
  permission policy:
    allows secretsmanager:GetSecretValue and DescribeSecret on one secret

EKS Pod Identity Association:
  namespace: external-secrets
  serviceAccount: external-secrets
  roleArn: arn:aws:iam::<account-id>:role/EksExternalSecretsCaseStudyRole
```

Kubernetes objects:

```text
Namespace: external-secrets
External Secrets Operator controller

Namespace: case-secrets-app
SecretStore: aws-secrets-manager
ExternalSecret: app-runtime-secret
Secret: app-runtime-secret
Job: secret-consumer-check
```

## Prerequisites

You need:

- AWS CLI v2.
- `kubectl`.
- Helm.
- An existing EKS cluster.
- Permission to create IAM roles, Pod Identity associations, and Secrets
  Manager secrets.
- Permission to install External Secrets Operator.

If your secret uses a customer-managed KMS key, the IAM policy also needs
`kms:Decrypt` for that key. The lab uses the default Secrets Manager encryption
path and does not add KMS permissions by default.

## Set Lab Variables

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/04-secrets-manager-to-pod
```

Set the lab values:

```bash
export CLUSTER_NAME=demo-batch16a
export AWS_REGION=us-east-2

export SECRET_NAME=batch16a/case-study/app-runtime
export SECRET_VALUE_JSON='{"username":"app_user","password":"ChangeMeForLabOnly123!"}'

export APP_NAMESPACE=case-secrets-app
export ROLE_NAME=EksExternalSecretsCaseStudyRole
```

## Step 1: Create Secrets Manager Access For The Controller

Run:

```bash
bash scripts/01-create-secret-and-eso-identity.sh
```

This script:

- Creates or updates the Secrets Manager secret.
- Installs External Secrets Operator with Helm.
- Ensures the EKS Pod Identity Agent add-on exists.
- Creates or updates the IAM Role and least-privilege secret read policy.
- Associates the IAM Role with the `external-secrets` ServiceAccount.
- Restarts the controller so it receives Pod Identity credentials.

## Step 2: Sync The Secret And Run The App Check

Run:

```bash
bash scripts/02-sync-and-run-secret-check.sh
```

This script:

- Applies the app Namespace.
- Renders and applies the `SecretStore` and `ExternalSecret`.
- Waits for the synced Kubernetes Secret.
- Runs a Job that consumes the Secret without printing the password.

Expected log pattern:

```text
Secret was injected into the Pod.
DB_USERNAME=app_user
DB_PASSWORD_LENGTH=<number>
```

## Step 3: Inspect The Sync

Check the ExternalSecret:

```bash
kubectl get externalsecret app-runtime-secret -n case-secrets-app
kubectl describe externalsecret app-runtime-secret -n case-secrets-app
```

Check the Kubernetes Secret exists:

```bash
kubectl get secret app-runtime-secret -n case-secrets-app
```

Avoid printing the secret value in shared terminals. If this is a private lab
and you intentionally want to inspect the decoded value:

```bash
kubectl get secret app-runtime-secret -n case-secrets-app \
  -o jsonpath='{.data.DB_USERNAME}' | base64 --decode
```

## How The Pieces Work Together

The Secrets Manager secret answers this question:

```text
Where does the source-of-truth secret value live?
```

The External Secrets Operator IAM Role answers this question:

```text
Which AWS secrets is the sync controller allowed to read?
```

The Pod Identity association answers this question:

```text
Which IAM Role should the external-secrets controller Pods receive?
```

The ExternalSecret answers this question:

```text
Which remote secret properties should become Kubernetes Secret keys?
```

The application Pod answers this question:

```text
Which Kubernetes Secret keys should be mounted or injected into the container?
```

## Production Guidance

- Keep external secret values out of Git.
- Give the sync controller access only to required secret ARNs.
- Use separate secrets per app and environment.
- Avoid logging secret values. Log presence, version, or length only when
  troubleshooting.
- Decide whether the Kubernetes Secret should be persisted or mounted directly
  through a CSI driver based on your audit and rotation requirements.
- Add rotation runbooks: update Secrets Manager, confirm ExternalSecret refresh,
  restart or reload workloads if the app does not watch secret changes.
- Use Kubernetes RBAC carefully. Anyone who can read the synced Kubernetes
  Secret can read the secret value.

## Cleanup

Run:

```bash
bash scripts/03-cleanup-secrets-manager-case.sh
```

The cleanup removes app-side Kubernetes objects, the Pod Identity association,
and the IAM Role. It does not uninstall External Secrets Operator by default
because other labs or workloads may use it.

To delete the AWS Secrets Manager secret too:

```bash
export DELETE_AWS_SECRET=true
bash scripts/03-cleanup-secrets-manager-case.sh
```

## References

- External Secrets Operator AWS provider: `https://external-secrets.io/latest/provider/aws-secrets-manager/`
- External Secrets Operator Helm install: `https://external-secrets.io/latest/introduction/getting-started/`
- AWS Secrets Manager identity and access: `https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access.html`
- EKS Pod Identity: `https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html`
