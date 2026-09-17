# Kubernetes Cluster Role Module Documentation

## Overview

This module manages a single cluster-scoped Kubernetes `ClusterRole` in an
existing cluster.

## Managed Resources

- `kubernetes_cluster_role_v1`

## Usage Notes

- Use this module for cluster-scoped read or administrative roles.
- `aggregation_rule` is supported when you need a label-driven composed role.
- Cluster roles should be granted carefully because they are not namespace-bound.

## Out of Scope

- ClusterRole bindings
- Namespace-scoped roles
- Namespace lifecycle
