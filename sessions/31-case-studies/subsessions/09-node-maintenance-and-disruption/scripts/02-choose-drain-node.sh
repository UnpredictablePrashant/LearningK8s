#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-node-maintenance}"

kubectl get pods -n "${NAMESPACE}" \
  -l app.kubernetes.io/name=drain-safe-web \
  -o wide

echo
echo "Candidate nodes hosting this workload:"
kubectl get pods -n "${NAMESPACE}" \
  -l app.kubernetes.io/name=drain-safe-web \
  -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort -u

cat <<'EOF'

Pick one candidate and export it before draining:
  export NODE_NAME=<node-name>

Inspect all Pods on the node first:
  kubectl get pods -A --field-selector spec.nodeName="$NODE_NAME" -o wide

EOF
