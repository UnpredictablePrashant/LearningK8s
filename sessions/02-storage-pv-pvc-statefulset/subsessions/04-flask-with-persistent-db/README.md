# Sub-Session 04: Flask With Persistent PostgreSQL

This sub-session deploys the Flask app and connects it to the PostgreSQL database that is using persistent storage.

## Why Flask Still Uses Deployment

Flask is stateless. It does not store the submitted messages in its local filesystem. It sends them to PostgreSQL.

That means Flask can safely run as a Deployment with multiple replicas.

## How Kubernetes Connects Flask To PostgreSQL

The Flask container receives:

```text
DB_HOST=postgres
DB_PORT=5432
```

`postgres` is the Kubernetes Service name for the database.

## Manifests

```text
01-flask-deployment.yml
02-flask-service.yml
```

The Service is a `LoadBalancer` so the app can be exposed on a cloud cluster. For local clusters, use port forwarding.

## Apply

Run either the static PostgreSQL sub-session or the StatefulSet sub-session first.

From `sessions/02-storage-pv-pvc-statefulset`:

```bash
kubectl apply -f subsessions/04-flask-with-persistent-db/
```

## Check

```bash
kubectl get deployment flask-web -n app-storage
kubectl get pods -n app-storage -l app=flask-web
kubectl get service flask-web -n app-storage
```

## Access

Local access:

```bash
kubectl port-forward -n app-storage service/flask-web 8080:80
```

Open:

```text
http://localhost:8080
```

Cloud access:

```bash
kubectl get service flask-web -n app-storage
```

Use the `EXTERNAL-IP` when it is available.

