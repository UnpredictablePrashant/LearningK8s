#!/usr/bin/env bash
set -euo pipefail

: "${NODE_NAME:?Set NODE_NAME to the node you drained}"

NAMESPACE="${NAMESPACE:-case-node-maintenance}"

kubectl uncordon "${NODE_NAME}"
kubectl get nodes
kubectl get pods -n "${NAMESPACE}" -o wide
