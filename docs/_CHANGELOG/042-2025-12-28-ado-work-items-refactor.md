# Filename: 042-2025-12-28-ado-work-items-refactor.md

# 042. Azure DevOps Work Items module refactor (single work item interface)

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_work_items/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-026

---

## Key Changes

- **Single work item input:** replaced the list interface with flat inputs and module-level `for_each` for multiple work items.
- **Stable keys everywhere:** list-based resources now use stable keys derived from `key`/`name` and outputs are keyed consistently.
- **Key-based references:** query permissions can target module-created folders/queries via `folder_key`/`query_key`.
- **Validations tightened:** non-empty checks, selector rules, and positive ID validation for parent IDs.
- **Docs & tests refreshed:** examples, import guide, unit tests, and Terratest fixtures updated to the new interface.
