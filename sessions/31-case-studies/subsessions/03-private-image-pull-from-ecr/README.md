# Case Study 03: Private Image Pull From ECR

## Scenario

A team built a container image and pushed it to a private Amazon ECR repository.
The Deployment works on the developer's laptop, but in EKS the Pod gets stuck in
`ImagePullBackOff`.

This is a production problem because private image pulls are part of almost
every real delivery pipeline. The important mental model is that image pull
permissions are used by the node's kubelet before the application container is
running. They are not the same as the Pod's runtime AWS permissions.

## Target Outcome

The cluster can:

- Pull a private image from Amazon ECR.
- Run the image in a dedicated Namespace.
- Prove the image tag, repository URI, and Pod rollout are correct.
- Show where to look when image pull fails.

The cluster should not:

- Store long-lived AWS access keys in `imagePullSecrets` for ECR.
- Use the application Pod's S3/DynamoDB/etc. role as the image-pull role.
- Grant broad `AdministratorAccess` to the node role.

## Important Concept

There are two different permission moments:

```text
Image pull time
  -> kubelet on the worker node authenticates to ECR
  -> node IAM role or Fargate pod execution role needs ECR pull permissions

Application runtime
  -> container code calls AWS APIs after the Pod starts
  -> ServiceAccount + Pod Identity or IRSA should grant app permissions
```

For normal EKS worker nodes, the node IAM role needs ECR pull permissions. For
EKS Fargate, the Fargate pod execution role needs those permissions.

## Request Flow

```text
Deployment references private ECR image
  -> scheduler places Pod on a node
    -> kubelet asks ECR for an authorization token and image layers
      -> IAM checks the node role's ECR permissions
        -> image layers download
          -> container starts
```

## Objects Created

AWS objects:

```text
ECR repository: <ECR_REPOSITORY>
Image tag: <IMAGE_TAG>

Optional node role inline policy:
  allows ECR token retrieval and image layer reads
```

Kubernetes objects:

```text
Namespace: case-ecr-pull
Deployment: private-ecr-app
Service: private-ecr-app
```

## Prerequisites

You need:

- AWS CLI v2.
- Docker.
- `kubectl`.
- An existing EKS cluster with worker nodes or Fargate.
- Permission to create or push to an ECR repository.
- Permission to update the node IAM role if it does not already have ECR pull
  permissions.

The repository uses the existing training app image source under
`app/frontend/` by default.

## Set Lab Variables

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/03-private-image-pull-from-ecr
```

Set the lab values:

```bash
export CLUSTER_NAME=demo-batch16a
export AWS_REGION=us-east-2

export ECR_REPOSITORY=batch16a/private-ecr-app
export IMAGE_TAG=v1
export NAMESPACE=case-ecr-pull
```

If your node role does not already have ECR pull permissions, also set one of
these:

```bash
export NODE_ROLE_NAME=replace-with-node-iam-role-name
```

or:

```bash
export NODEGROUP_NAME=standard-workers
```

## Step 1: Build And Push The Private Image

Run:

```bash
bash scripts/01-build-and-push-ecr-image.sh
```

This script:

- Creates the ECR repository if it does not exist.
- Logs Docker in to ECR.
- Builds the training frontend image.
- Pushes the image to ECR.
- Optionally attaches the least-privilege ECR pull policy to the node role when
  `NODE_ROLE_NAME` or `NODEGROUP_NAME` is set.

The script prints the final `ECR_IMAGE_URI`.

## Step 2: Deploy The Private Image

Run:

```bash
export ECR_IMAGE_URI=<value-printed-by-step-1>
bash scripts/02-apply-private-ecr-workload.sh
```

Check the rollout:

```bash
kubectl rollout status deployment/private-ecr-app -n case-ecr-pull
kubectl get pods -n case-ecr-pull -o wide
kubectl get service private-ecr-app -n case-ecr-pull
```

## Step 3: Troubleshoot ImagePullBackOff

If the Pod does not start:

```bash
kubectl get pods -n case-ecr-pull
kubectl describe pod -n case-ecr-pull -l app.kubernetes.io/name=private-ecr-app
kubectl get events -n case-ecr-pull --sort-by=.lastTimestamp
```

Common event patterns:

```text
no basic auth credentials
  -> node cannot authenticate to ECR

pull access denied
  -> repository URI, tag, account, region, or repository policy is wrong

manifest unknown
  -> image tag was not pushed

403 Forbidden
  -> node role or cross-account repository policy is missing pull permissions
```

## Step 4: Prove It Is The Node Pull Role

Check which node ran the Pod:

```bash
kubectl get pod -n case-ecr-pull \
  -l app.kubernetes.io/name=private-ecr-app \
  -o wide
```

For a managed node group, find the node IAM role:

```bash
aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --query 'nodegroup.nodeRole' \
  --output text
```

That role, not the app's Kubernetes ServiceAccount, is what needs ECR image
pull permission.

## Production Guidance

- Keep image pull permission separate from application AWS permissions.
- Prefer node role or Fargate pod execution role permissions for ECR on EKS.
- Use repository-specific ECR permissions where practical.
- For cross-account ECR, configure both sides: the pulling role needs IAM
  permissions and the ECR repository needs a repository policy that trusts it.
- Avoid long-lived registry credentials in Kubernetes Secrets for ECR.
- Pin production images by immutable tag or digest.
- Use image scanning and admission policy for production promotion gates.

## Cleanup

Remove the Kubernetes workload:

```bash
bash scripts/03-cleanup-private-ecr-workload.sh
```

The cleanup script does not delete the ECR repository by default. To delete the
lab repository too:

```bash
export DELETE_ECR_REPOSITORY=true
bash scripts/03-cleanup-private-ecr-workload.sh
```

It also does not remove any node role policy that you attached manually. Review
the node role before removing shared cluster permissions.

## References

- Amazon ECR on EKS: `https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_EKS.html`
- Amazon ECR private repository policies: `https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html`
- Amazon ECR IAM permissions: `https://docs.aws.amazon.com/AmazonECR/latest/userguide/security-iam.html`
- Kubernetes image pull documentation: `https://kubernetes.io/docs/concepts/containers/images/`
