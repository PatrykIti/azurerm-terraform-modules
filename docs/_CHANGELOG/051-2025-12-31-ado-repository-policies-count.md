# Filename: 051-2025-12-31-ado-repository-policies-count.md

# 051. Azure DevOps Repository policies - count-based repo policies

**Date:** 2025-12-31  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_repository/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-029

---

## Key Changes

- Switched repository-level policy resources to `count` (single instance) instead of `for_each`; addresses now use `[0]` when enabled.
- Updated `policy_ids` output handling and import documentation for the new count-based repo policies.
- Set `policies` default to `{}` with `nullable = false` to avoid null guards.
