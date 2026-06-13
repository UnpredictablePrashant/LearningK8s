# Sub-Session 01: Storage Problem And Shared Config

This sub-session explains why storage matters and creates the shared objects needed by the app.

## Why Storage Matters

Containers are replaceable. A Pod can be deleted, recreated, or moved. Files written inside the container filesystem are not a reliable place for database data.

In this app:

- Flask is stateless. It serves requests and talks to the database.
- PostgreSQL is stateful. It stores messages submitted through the UI.

If PostgreSQL data is stored only inside the container filesystem, messages can disappear when the Pod is replaced.

## Objects Created In This Step

This sub-session creates:

- Namespace: `app-storage`
- ConfigMap: `app-config`
- Secret: `app-secrets`

These are shared by both the static PV/PVC lab and the StatefulSet lab.

## Why ConfigMap Is Used

The Flask app needs database connection settings such as host and port. These are environment-specific and should not be hardcoded into the image.

## Why Secret Is Used

PostgreSQL credentials should not be stored in the Docker image or app source code. Kubernetes Secrets provide them to the Pods as environment variables.

## Apply

From `sessions/02-storage-pv-pvc-statefulset`:

```bash
kubectl apply -f subsessions/01-storage-problem-and-shared-config/
```

## Check

```bash
kubectl get namespace app-storage
kubectl get configmap -n app-storage
kubectl get secret -n app-storage
```

