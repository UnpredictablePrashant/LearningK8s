# Case Study 07: Pod Cannot Connect To Database

## Scenario

The application Pod is running, the database Pod is running, but the app cannot
connect to the database. In production this usually shows up as connection
timeouts, startup failures, or readiness probe failures.

This lab creates a deterministic failure: the database Service has the wrong
selector, so it has no endpoints. Students diagnose the Service path, fix the
selector, and prove the client can connect.

## Target Outcome

The team can:

- Confirm the database Pod is actually running.
- Check Service DNS, Service selector, and Endpoints.
- Run a client Pod that uses the same Secret and Service DNS as the app.
- Fix a Service selector and confirm endpoints appear.
- Re-run the client check successfully.

The team should not:

- Restart every Pod blindly.
- Change database credentials before proving the network path.
- Assume a Service has endpoints just because the Service object exists.
- Ignore labels and selectors.

## Request Flow

```text
Client Pod connects to postgres-db.case-db-connectivity.svc.cluster.local
  -> CoreDNS resolves the Service name
    -> kube-proxy or CNI routes traffic to Service endpoints
      -> Service has no endpoints because selector is wrong
        -> connection fails
          -> operator compares Service selector with Pod labels
            -> selector is fixed
              -> endpoints appear
                -> client connection succeeds
```

## Objects Created

```text
Namespace: case-db-connectivity
Secret: postgres-credentials
Deployment: postgres-db
Service: postgres-db
Job: db-connectivity-check
```

The first Service manifest is intentionally broken:

```text
Service selector:
  app.kubernetes.io/name: postgres-db-typo

Pod label:
  app.kubernetes.io/name: postgres-db
```

## Step 1: Deploy The Broken Stack

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/07-pod-cannot-connect-to-database
bash scripts/01-deploy-broken-db-stack.sh
```

Check:

```bash
kubectl get pods -n case-db-connectivity
kubectl get service postgres-db -n case-db-connectivity
kubectl get endpoints postgres-db -n case-db-connectivity
kubectl get pods -n case-db-connectivity --show-labels
```

Expected issue:

```text
The database Pod is running, but the Service has no endpoints.
```

## Step 2: Run The Failing Client Check

Run:

```bash
bash scripts/02-run-failing-db-check.sh
```

Expected behavior:

```text
pg_isready
  -> no response or connection timeout
```

## Step 3: Diagnose The Selector

Compare the Service selector and Pod labels:

```bash
kubectl describe service postgres-db -n case-db-connectivity
kubectl get pods -n case-db-connectivity --show-labels
```

The Service selector must match labels on the target Pods.

## Step 4: Fix The Service

Run:

```bash
bash scripts/03-fix-service-selector.sh
```

Confirm endpoints now exist:

```bash
kubectl get endpoints postgres-db -n case-db-connectivity
kubectl get endpointslices -n case-db-connectivity \
  -l kubernetes.io/service-name=postgres-db
```

## Step 5: Run The Successful Client Check

Run:

```bash
bash scripts/04-run-success-db-check.sh
```

Expected behavior:

```text
pg_isready
  -> accepting connections

psql select 1
  -> succeeds
```

## Production Troubleshooting Checklist

When an app cannot connect to a database, check in this order:

```text
1. Is the client Pod running and using the expected config?
2. Is the database hostname correct?
3. Does DNS resolve?
4. Does the Service have endpoints?
5. Do Service selectors match Pod labels?
6. Are the target Pods ready?
7. Is the target port correct?
8. Are NetworkPolicies blocking traffic?
9. For RDS or external DBs, do security groups allow the connection?
10. Are credentials and database names correct?
```

## How The Pieces Work Together

The Secret answers this question:

```text
Which credentials should the client use?
```

The Service answers this question:

```text
Which stable DNS name and virtual IP should clients use?
```

The Service selector answers this question:

```text
Which Pods should receive traffic?
```

Endpoints or EndpointSlices answer this question:

```text
Which ready Pod IPs are actually behind the Service right now?
```

The client Job answers this question:

```text
Can a Pod in the same cluster connect the way the application would?
```

## Cleanup

```bash
bash scripts/05-cleanup-db-connectivity-case.sh
```

## References

- Kubernetes Services: `https://kubernetes.io/docs/concepts/services-networking/service/`
- EndpointSlices: `https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/`
- DNS for Services and Pods: `https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/`
- Debug Services: `https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/`
