# Filename: 088-2026-02-13-ado-agent-pools-group-atomic-boundary-split.md

# 088. Azure DevOps agent pools/group atomic boundary split

**Date:** 2026-02-13  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_agent_pools/*`, `modules/azuredevops_elastic_pool/*`, `modules/azuredevops_group/*`, `modules/azuredevops_group_entitlement/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-042, TASK-ADO-043

---

## Key Changes

- Split independent `elastic_pool` scope out of `azuredevops_agent_pools` into new atomic module `azuredevops_elastic_pool`.
- Narrowed `azuredevops_group` to primary group + strict-child memberships only.
- Removed membership external fallback (`group_descriptor`) from `azuredevops_group` interface.
- Split independent entitlement scope into new atomic module `azuredevops_group_entitlement`.
- Updated docs/examples/tests/release metadata and marked TASK-ADO-042/TASK-ADO-043 as done on the task board.
