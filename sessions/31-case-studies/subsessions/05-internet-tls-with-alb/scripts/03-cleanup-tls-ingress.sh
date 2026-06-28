#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-tls-ingress}"

kubectl delete ingress tls-demo -n "${NAMESPACE}" --ignore-not-found
kubectl delete service tls-demo -n "${NAMESPACE}" --ignore-not-found
kubectl delete deployment tls-demo -n "${NAMESPACE}" --ignore-not-found
kubectl delete namespace "${NAMESPACE}" --ignore-not-found

echo "TLS Ingress case study cleanup finished. Remove any DNS record separately."
