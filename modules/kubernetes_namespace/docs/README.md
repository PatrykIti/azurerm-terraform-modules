# Kubernetes Namespace Module Documentation

## Overview

This module manages a single Kubernetes namespace in an existing cluster.
It is an in-cluster module and uses the `kubernetes` provider, not `azurerm`.

## Managed Resources

- `kubernetes_namespace_v1`

## Usage Notes

- The target cluster must already exist before applying this module.
- Configure provider authentication outside the module via kubeconfig or
  explicit `host`, `token`, and `cluster_ca_certificate`.
- This module is intentionally limited to namespace lifecycle only.

## Out of Scope

- `Role` / `RoleBinding`
- `ClusterRole` / `ClusterRoleBinding`
- `ResourceQuota`
- `LimitRange`
- `NetworkPolicy`
- Workloads such as `Deployment` or `Pod`
