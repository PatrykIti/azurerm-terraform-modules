# Filename: 032-2025-12-26-ado-work-items-refactor.md

# 032. Azure DevOps Work Items module refactor

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_work_items/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-026

---

## Key Changes

- **Stable keys + references:** list inputs now support `key` fields with key-based lookups for parent work items, query folders, and queries.
- **Project scoping:** `project_id` is optional with validation to ensure project-scoped entries resolve a project ID.
- **Stronger validation:** added key uniqueness, selector rules, and positive ID/path checks.
- **Outputs expanded:** added stable maps for query folders and all permission resources.
- **Docs & tests:** refreshed examples, fixtures, unit/integration tests, and added import guidance.
