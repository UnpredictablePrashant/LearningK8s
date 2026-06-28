#!/usr/bin/env bash
set -euo pipefail

echo "Team A group checks"
kubectl auth can-i list pods -n case-tenant-a --as=tenant-check --as-group=case-tenant-a-developers
kubectl auth can-i list pods -n case-tenant-b --as=tenant-check --as-group=case-tenant-a-developers
kubectl auth can-i get secrets -n case-tenant-a --as=tenant-check --as-group=case-tenant-a-developers
kubectl auth can-i list nodes --as=tenant-check --as-group=case-tenant-a-developers

echo
echo "Team B group checks"
kubectl auth can-i list pods -n case-tenant-b --as=tenant-check --as-group=case-tenant-b-developers
kubectl auth can-i list pods -n case-tenant-a --as=tenant-check --as-group=case-tenant-b-developers
kubectl auth can-i get secrets -n case-tenant-b --as=tenant-check --as-group=case-tenant-b-developers
kubectl auth can-i list nodes --as=tenant-check --as-group=case-tenant-b-developers
