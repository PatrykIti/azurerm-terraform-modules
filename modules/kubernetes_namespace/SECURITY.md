# kubernetes_namespace Module Security

## Overview

This module manages only a namespace object. Security posture for the namespace
is mostly driven by what other in-cluster resources are later attached to it.

## Guidance

- Use labels and annotations consistently to support policy, ownership, and
  auditability.
- Keep RBAC separate and explicit through dedicated modules.
- Do not assume namespace creation alone creates isolation; network policy,
  quotas, and RBAC must be layered separately.
