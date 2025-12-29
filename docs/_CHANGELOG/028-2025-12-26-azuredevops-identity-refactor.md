# Filename: 028-2025-12-26-azuredevops-identity-refactor.md

# 028. Azure DevOps Identity module refactor

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_identity/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-018

---

## Key Changes

- **Stable keys:** added optional `key` fields and normalized `for_each` maps for memberships, entitlements, and role assignments.
- **Validation tightened:** cross-checks for group references, selector rules for entitlements, unique derived keys, and default membership mode.
- **Outputs updated:** outputs now keyed by stable keys, plus new `securityrole_assignment_ids`.
- **Docs & tests:** refreshed examples/fixtures, added import guidance, and expanded unit/integration coverage.
