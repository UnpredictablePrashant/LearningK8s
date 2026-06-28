#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace case-tenant-a --ignore-not-found
kubectl delete namespace case-tenant-b --ignore-not-found
echo "Namespace tenant isolation case study cleanup finished."
