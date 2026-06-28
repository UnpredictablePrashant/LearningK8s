# Scheduling, Autoscaling, And Cost Capstone

Capstone Level: 3 of 5

## Problem Statement

Traffic is unpredictable and the platform team is worried about both outages
and waste. Your team must design placement, resource, and scaling controls that
keep the app available while making capacity choices visible and defensible.

## Estimated Effort

8 to 12 hours, including load testing, autoscaling observation, node placement
experiments, and cost notes.

## Correlated Kubernetes Topics

- Requests, limits, QoS classes, LimitRange, and ResourceQuota.
- Node selectors, node affinity, pod affinity, and pod anti-affinity.
- Taints, tolerations, PriorityClasses, and preemption.
- Topology spread constraints and zone awareness.
- HPA, VPA, and metrics-server.
- Cluster Autoscaler, Karpenter, or EKS Auto Mode.
- PDBs and maintenance windows.
- Cost and capacity review.

## Required Scope

- Define resource requests and limits for all app tiers.
- Add namespace quota and default resource policy.
- Place critical and non-critical workloads intentionally.
- Spread stateless replicas across nodes or zones.
- Add PDBs for workloads that must survive node drains.
- Configure HPA for at least one stateless tier.
- Use VPA recommendation mode or document why it is not installed.
- Trigger scale-out with a load generator and capture evidence.
- Demonstrate one scheduling failure and explain how to fix it.
- Estimate cost impact of requests, limits, replicas, and node type choice.

## AWS Touchpoints

- Managed node groups, Karpenter, Cluster Autoscaler, or EKS Auto Mode.
- EC2 instance type choice and capacity type.
- Availability zones and subnet placement.
- CloudWatch, Prometheus, or metrics-server evidence for utilization.

## Deliverables

- Capacity design notes for baseline and peak traffic.
- Manifests for requests, limits, quotas, PDBs, HPA, scheduling constraints, and
  optional PriorityClasses.
- Load test procedure and scaling evidence.
- Scheduling failure report.
- Cost review with at least three concrete tuning options.
- Maintenance or node-drain runbook.

## Acceptance Criteria

- Workloads have explicit requests and limits.
- HPA scales a workload under load or the limitation is clearly documented.
- A node drain preserves availability according to the PDB design.
- Scheduling constraints do not accidentally make the app unschedulable.
- The team can explain the cost of over-requesting and under-requesting.
- Students can connect scheduling choices to autoscaling behavior.

## Review Prompts

1. Which workload should scale horizontally first?
2. What happens if requests are too high for available nodes?
3. How do topology spread constraints affect node autoscaling?
4. What is protected by a PDB, and what is not?
5. Which cost change would you make first and why?
