# Filename: 090-2026-02-14-ado-pipelines-work-items-atomic-realignment.md

# 090. Azure DevOps pipelines/work-items atomic realignment

**Date:** 2026-02-14  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_pipelines/*`, `modules/azuredevops_work_items/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-021, TASK-ADO-026, TASK-ADO-039 (in progress)

---

## Key Changes

- Narrowed `azuredevops_pipelines` to a single primary resource (`azuredevops_build_definition`) with strict-child-only retained resources.
- Removed non-child scopes from `azuredevops_pipelines`: build folders, build folder permissions, and legacy resource authorizations.
- Narrowed `azuredevops_work_items` to a single primary resource (`azuredevops_workitem`).
- Removed non-child scopes from `azuredevops_work_items`: process/query/query-folder and query/area/iteration/tagging permissions families.
- Updated examples, fixtures, unit tests, and integration compile checks for both modules.
- Refreshed task board state: `TASK-ADO-021` and `TASK-ADO-026` moved to done; `TASK-ADO-039` remains in progress pending release tag normalization.

## Release-Tag Policy Note

- Historical non-`v` tags remain unchanged.
- Target convention stays `tag_prefix + vX.Y.Z` and is tracked under `TASK-ADO-039`.
