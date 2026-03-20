# Kubernetes Cluster Role Binding Module Documentation

## Overview

This module manages a single cluster-scoped Kubernetes `ClusterRoleBinding` in
an existing cluster.

## Managed Resources

- `kubernetes_cluster_role_binding_v1`

## Usage Notes

- The referenced `ClusterRole` must already exist.
- Subjects can be `User`, `Group`, or `ServiceAccount`.
- Bind cluster-wide permissions carefully because they apply across namespaces.
