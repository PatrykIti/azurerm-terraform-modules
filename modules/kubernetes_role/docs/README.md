# Kubernetes Role Module Documentation

## Overview

This module manages a single namespace-scoped Kubernetes `Role` in an existing
cluster. It uses the `kubernetes` provider and is intended for in-cluster RBAC.

## Managed Resources

- `kubernetes_role_v1`

## Usage Notes

- The target namespace must already exist before applying this module.
- This module is namespace-scoped and should be paired with
  `kubernetes_role_binding` to grant access to subjects.
- Use this module for least-privilege grants such as:
  - read access to pods/services/endpoints
  - `pods/portforward`
  - narrowly scoped resource names

## Out of Scope

- Namespace creation
- Role bindings
- Cluster-scoped RBAC
- Workload resources
