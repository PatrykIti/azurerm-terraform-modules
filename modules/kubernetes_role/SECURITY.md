# kubernetes_role Module Security

## Overview

This module defines namespace-scoped Kubernetes RBAC rules. Security risk is
driven entirely by the rules you allow.

## Guidance

- Prefer explicit resources and verbs over wildcards.
- Use separate Roles for read access and mutation access where possible.
- Treat `pods/portforward` as privileged access and grant it separately when feasible.
- Use `resource_names` to narrow grants when stable object names exist.
