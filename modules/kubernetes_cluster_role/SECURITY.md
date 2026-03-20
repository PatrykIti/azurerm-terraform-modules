# kubernetes_cluster_role Module Security

## Overview

This module defines cluster-scoped Kubernetes permissions. Misconfiguration can
affect every namespace in the cluster.

## Guidance

- Use explicit resources and verbs; avoid wildcards.
- Prefer namespace-scoped `Role` where cluster-wide scope is not required.
- Use `non_resource_urls` sparingly.
- Review every `ClusterRole` as privileged infrastructure code.
