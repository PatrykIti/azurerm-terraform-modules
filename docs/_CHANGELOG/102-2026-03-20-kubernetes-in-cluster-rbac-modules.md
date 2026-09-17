# 102 - 2026-03-20 - Kubernetes in-cluster namespace and RBAC modules

## Summary

Added a new family of `kubernetes_*` modules for managing in-cluster namespace
and RBAC resources with Terraform, together with repository-level naming,
documentation, and index support for Kubernetes-scoped modules.

## Changes

- Added new modules:
  - `modules/kubernetes_namespace`
  - `modules/kubernetes_role`
  - `modules/kubernetes_role_binding`
  - `modules/kubernetes_cluster_role`
  - `modules/kubernetes_cluster_role_binding`
- Added README, `docs/README.md`, `docs/IMPORT.md`, `SECURITY.md`, `basic`,
  `complete`, and `secure` examples for all five modules.
- Added `terraform test` unit coverage, Terratest scaffolding, and AKS-backed
  live fixtures for all five modules using the same harness style as existing
  AKS/PGFS patterns.
- Extended repository naming guidance and scaffolding support to treat
  `kubernetes_*` as a first-class module family.
- Updated root/module indexes and changelog/task tracking docs for the new
  Kubernetes module family.

## Impact

- New in-cluster Kubernetes modules are available in development for namespace
  lifecycle and RBAC management.
- Repository tooling no longer assumes only `azurerm_*` and `azuredevops_*`
  module prefixes.
