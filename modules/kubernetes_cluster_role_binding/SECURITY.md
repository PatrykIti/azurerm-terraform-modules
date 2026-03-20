# kubernetes_cluster_role_binding Module Security

## Overview

This module grants cluster-wide permissions by binding a ClusterRole to
subjects.

## Guidance

- Prefer groups over individual users.
- Use cluster-wide grants only when namespace-scoped bindings are insufficient.
- For service accounts, always specify namespace.
