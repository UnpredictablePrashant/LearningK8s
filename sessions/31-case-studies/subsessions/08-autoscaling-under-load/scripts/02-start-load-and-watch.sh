#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-autoscaling}"
WATCH_ITERATIONS="${WATCH_ITERATIONS:-12}"
WATCH_SLEEP_SECONDS="${WATCH_SLEEP_SECONDS:-15}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

sed \
  -e "s|case-autoscaling|${NAMESPACE}|g" \
  "${CASE_DIR}/03-load-generator.yml" | kubectl apply -f -

kubectl rollout status deployment/load-generator -n "${NAMESPACE}" --timeout=120s

for _ in $(seq 1 "${WATCH_ITERATIONS}"); do
  date
  kubectl get hpa scale-demo -n "${NAMESPACE}" || true
  kubectl get deployment scale-demo -n "${NAMESPACE}"
  kubectl top pods -n "${NAMESPACE}" 2>/dev/null || true
  echo
  sleep "${WATCH_SLEEP_SECONDS}"
done
