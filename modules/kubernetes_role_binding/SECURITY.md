# kubernetes_role_binding Module Security

## Overview

This module grants namespace-scoped permissions by binding a Role or
ClusterRole to subjects.

## Guidance

- Prefer binding groups over individual users where possible.
- Keep subject lists explicit and review them regularly.
- Be deliberate when binding a `ClusterRole` inside a namespace.
- For service accounts, always specify namespace explicitly.
