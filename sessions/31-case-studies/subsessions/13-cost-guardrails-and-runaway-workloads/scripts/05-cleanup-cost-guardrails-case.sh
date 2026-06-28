#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-cost-guardrails}"

kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo "Cost guardrails case study cleanup finished."
