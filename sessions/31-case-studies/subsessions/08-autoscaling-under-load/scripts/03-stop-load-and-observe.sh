#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-case-autoscaling}"

kubectl delete deployment load-generator -n "${NAMESPACE}" --ignore-not-found

kubectl get hpa scale-demo -n "${NAMESPACE}" || true
kubectl describe hpa scale-demo -n "${NAMESPACE}" || true
kubectl get deployment scale-demo -n "${NAMESPACE}"

cat <<EOF

Load stopped.
Scale-down may take several minutes because the HPA has a stabilization window.

Watch:
  kubectl get hpa scale-demo -n ${NAMESPACE} -w
  kubectl get deployment scale-demo -n ${NAMESPACE} -w

EOF
