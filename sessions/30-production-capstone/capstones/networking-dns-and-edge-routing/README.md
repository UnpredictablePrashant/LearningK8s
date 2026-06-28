# Networking, DNS, And Edge Routing Capstone

Capstone Level: 2 of 5

## Problem Statement

The application works only when engineers port-forward to individual Pods. Your
team must design the full traffic path from an external user to the correct Pod,
then lock down east-west traffic so only expected communication is allowed.

## Estimated Effort

8 to 12 hours, including traffic diagrams, implementation, TLS validation,
denied-traffic tests, and troubleshooting evidence.

## Correlated Kubernetes Topics

- Pod IPs, Service selectors, EndpointSlices, and kube-proxy behavior.
- ClusterIP, NodePort, LoadBalancer, Ingress, and Gateway API.
- CoreDNS and service discovery.
- TLS termination and certificate management.
- AWS Load Balancer Controller or another edge controller.
- NetworkPolicy and CNI enforcement.
- Optional service mesh traffic management and mTLS.
- Observability for network failures.

## Required Scope

- Expose internal app tiers with ClusterIP Services.
- Expose the frontend through Ingress or Gateway API.
- Configure TLS with cert-manager, ACM, or documented placeholder values.
- Prove DNS resolution inside the cluster with a debug Pod.
- Show EndpointSlice changes as Pods become ready or unready.
- Add NetworkPolicy with default deny and explicit app flow allows.
- Add a denied-traffic test from an unauthorized Pod.
- Troubleshoot at least one broken selector, DNS, certificate, or policy issue.
- Optionally add service mesh mTLS or traffic splitting for one route.

## AWS Touchpoints

- Load balancer, target group, listener, and security group created by the edge
  controller.
- Route 53 record or documented DNS plan.
- ACM certificate or cert-manager DNS validation.
- VPC CNI behavior and security group considerations.

## Deliverables

- Traffic flow diagram from browser to Pod and service-to-service calls.
- Manifests for Services, Ingress or Gateway API, TLS, and NetworkPolicy.
- Validation commands for DNS, endpoints, TLS, and allowed or denied traffic.
- Troubleshooting notes for the intentionally broken network issue.
- Cleanup commands for Kubernetes and AWS-created edge resources.

## Acceptance Criteria

- Users can reach the frontend through the chosen external route.
- Internal APIs are not directly exposed to the internet.
- DNS names resolve correctly inside the cluster.
- NetworkPolicy blocks unauthorized traffic.
- A broken routing issue can be diagnosed using Kubernetes resources and logs.
- Students can explain where Kubernetes routing ends and AWS routing begins.

## Review Prompts

1. What decides which Pods receive traffic for a Service?
2. How do readiness probes affect EndpointSlices?
3. Which component owns TLS termination?
4. What traffic is allowed after default deny is applied?
5. Which command best proves the problem is DNS, Service selection, or policy?
