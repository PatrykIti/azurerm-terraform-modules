# Kubernetes Role Binding Module Documentation

## Overview

This module manages a single namespace-scoped Kubernetes `RoleBinding` in an
existing cluster.

## Managed Resources

- `kubernetes_role_binding_v1`

## Usage Notes

- The target namespace and referenced role must already exist.
- Subjects can be `User`, `Group`, or `ServiceAccount`.
- For `ServiceAccount` subjects, namespace must be provided explicitly.

## Out of Scope

- Namespace lifecycle
- Role lifecycle
- Cluster-scoped RBAC
