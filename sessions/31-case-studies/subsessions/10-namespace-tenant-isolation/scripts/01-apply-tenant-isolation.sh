#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

kubectl apply -f "${CASE_DIR}/01-team-a-tenant.yml"
kubectl apply -f "${CASE_DIR}/02-team-b-tenant.yml"

kubectl rollout status deployment/tenant-web -n case-tenant-a --timeout=180s
kubectl rollout status deployment/tenant-web -n case-tenant-b --timeout=180s

kubectl get rolebinding,role,resourcequota,limitrange,networkpolicy -n case-tenant-a
kubectl get rolebinding,role,resourcequota,limitrange,networkpolicy -n case-tenant-b
