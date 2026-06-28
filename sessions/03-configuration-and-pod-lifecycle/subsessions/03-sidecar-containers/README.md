# Sub-Session 03: Sidecar Containers

This sub-session is part of 03-configuration-and-pod-lifecycle.

## Goal

Understand how helper containers run beside the main application container in
the same Pod, why sidecars are useful, and when a sidecar is the wrong tool.

By the end of this sub-session, students should be able to:

- Explain what a sidecar container shares with the main container.
- Compare sidecars, init containers, and ephemeral debug containers.
- Inspect logs and container status for a multi-container Pod.
- Prove that containers in the same Pod share the network namespace.
- Prove that containers in the same Pod can exchange files through a shared
  volume.
- Decide whether to model a helper as a regular app container sidecar or as a
  native sidecar-style init container.

## Mental Model

A Pod is the smallest deployable unit in Kubernetes. A Pod can contain one or
more containers. Those containers are scheduled together and run on the same
node.

```text
Pod: message-board-sidecar

  containers:
    app
      -> runs the Flask message board
      -> listens on localhost:5000 inside the Pod

    health-watcher
      -> runs beside the app
      -> calls http://127.0.0.1:5000
      -> writes observations to a shared emptyDir volume

  shared:
    network namespace
    Pod IP
    localhost
    volumes mounted into both containers
```

A sidecar is not a smaller Pod. It is another container in the same Pod. It
should support the main application without owning the primary business logic.

## Common Sidecar Use Cases

- Log shipping or log transformation.
- Local reverse proxy or service mesh proxy.
- Metrics exporter for an application that does not expose Prometheus metrics.
- Config watcher or file reloader.
- Certificate or token refresh helper.
- Small helper process that must share localhost or a volume with the app.

## Sidecar vs Init vs Ephemeral Container

| Container type | Runs when | Typical purpose | Example |
| --- | --- | --- | --- |
| Init container | Before app containers | Setup that must complete first | Wait for DNS, template config, prepare files |
| Regular sidecar container | Alongside app containers | Continuous helper process | Log shipper, local proxy, metrics exporter |
| Native sidecar-style init container | Starts before app containers and keeps running | Helper that needs startup ordering | Proxy or log shipper that must be ready first |
| Ephemeral container | Added later for debugging | Troubleshooting a live Pod | `kubectl debug` shell or toolbox |

## Important Behaviors

- Containers in the same Pod share one Pod IP.
- Containers in the same Pod can talk to each other through `localhost`.
- Containers do not automatically share filesystems.
- Use a shared volume, such as `emptyDir`, when containers need to exchange
  files.
- Each container has its own image, command, logs, process tree, and resource
  requests.
- A failing sidecar can keep a Pod unhealthy or noisy even when the main app is
  fine.
- Keep sidecars small, observable, and resource-limited.

## App-Based Lab 1: Regular Sidecar

This lab runs the existing message board application with a `busybox` sidecar.
The sidecar calls the app over `localhost` and writes the result into a shared
volume.

Apply the default lab from the session root:

```bash
kubectl apply -f subsessions/03-sidecar-containers/01-regular-sidecar-log-tailer.yml
```

Check the Deployment and Pod:

```bash
kubectl get deploy,pod,svc -n lifecycle-lab
kubectl get pod -n lifecycle-lab -l app=message-board-sidecar
```

Save the Pod name:

```bash
POD=$(kubectl get pod -n lifecycle-lab -l app=message-board-sidecar -o jsonpath='{.items[0].metadata.name}')
echo $POD
```

Inspect both containers:

```bash
kubectl describe pod "$POD" -n lifecycle-lab
kubectl logs "$POD" -n lifecycle-lab -c app --tail=20
kubectl logs "$POD" -n lifecycle-lab -c health-watcher --tail=20
```

Prove the shared network namespace:

```bash
kubectl exec "$POD" -n lifecycle-lab -c health-watcher -- wget -q -O - http://127.0.0.1:5000/ | head
```

Prove the shared volume:

```bash
kubectl exec "$POD" -n lifecycle-lab -c app -- cat /shared/sidecar-health.log
kubectl exec "$POD" -n lifecycle-lab -c health-watcher -- tail -n 5 /shared/sidecar-health.log
```

Restart only the sidecar container process and observe the Pod:

```bash
kubectl exec "$POD" -n lifecycle-lab -c health-watcher -- sh -c 'kill 1'
kubectl get pod "$POD" -n lifecycle-lab
kubectl describe pod "$POD" -n lifecycle-lab
```

The Pod should stay the same Pod, but the `health-watcher` container restart
count should increase.

## App-Based Lab 2: Native Sidecar Style

Kubernetes also supports a sidecar style where the helper is declared under
`initContainers` with `restartPolicy: Always`. This gives the sidecar init-style
startup ordering while still letting it continue running beside the main app.

Use this optional lab after Lab 1, or create the `lifecycle-lab` namespace first.
Then confirm your cluster supports native sidecar containers:

```bash
kubectl create namespace lifecycle-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl version
kubectl explain pod.spec.initContainers.restartPolicy
kubectl apply -f subsessions/03-sidecar-containers/examples/02-native-sidecar-init-style.yml
```

If `kubectl explain` cannot find `restartPolicy` under `initContainers`, skip
this optional lab for that cluster.

Inspect the native sidecar:

```bash
POD=$(kubectl get pod -n lifecycle-lab -l app=message-board-native-sidecar -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$POD" -n lifecycle-lab
kubectl logs "$POD" -n lifecycle-lab -c native-log-shipper --tail=20
kubectl exec "$POD" -n lifecycle-lab -c app -- cat /shared/native-sidecar.log
```

Compare the status sections:

```bash
kubectl get pod "$POD" -n lifecycle-lab -o jsonpath='{.status.initContainerStatuses[*].name}{"\n"}'
kubectl get pod "$POD" -n lifecycle-lab -o jsonpath='{.status.containerStatuses[*].name}{"\n"}'
```

## Discussion

Use these questions after the lab:

1. Why is the sidecar in the same Pod instead of a separate Deployment?
2. What exactly is shared between the app container and the sidecar?
3. What is not shared automatically?
4. How would a sidecar failure show up in `kubectl get pod` and
   `kubectl describe pod`?
5. When would a separate Deployment plus Service be better than a sidecar?
6. Why might a service mesh inject a proxy as a sidecar?
7. Why can too many sidecars make a cluster harder to operate?

## Production Notes

- Put CPU and memory requests on every sidecar.
- Give the sidecar its own readiness and liveness probes when it serves traffic
  or gates application readiness.
- Avoid hiding critical business behavior in a sidecar.
- Keep sidecar images patched just like app images.
- Remember that every sidecar increases Pod resource usage.
- In a Deployment, changing sidecar configuration changes the Pod template and
  causes a rollout.
- In short-lived Jobs, use native sidecar behavior when the sidecar should not
  prevent the Job from completing.

## Cleanup

```bash
kubectl delete -f subsessions/03-sidecar-containers/examples/02-native-sidecar-init-style.yml --ignore-not-found
kubectl delete -f subsessions/03-sidecar-containers/01-regular-sidecar-log-tailer.yml --ignore-not-found
```

## Reference Docs

- Kubernetes sidecar containers: <https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/>
- Kubernetes init containers: <https://kubernetes.io/docs/concepts/workloads/pods/init-containers/>

## Review Prompts

1. What problem does the sidecar solve in this lab?
2. Which command proves that the sidecar and app share localhost?
3. Which command proves that the sidecar and app share a volume?
4. How is a sidecar different from an init container?
5. What should you check before adding a sidecar to a production Pod?
