# Filename: 046-2025-12-28-ado-repository-refactor.md

# 046. Azure DevOps Repository module - refactor (re-opened alignment)

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_repository/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-023

---

## Key Changes

- **Single repository resource:** flattened inputs for `azuredevops_git_repository` with optional initialization and module-level `for_each` for multi-repo usage.
- **Stable list keys + validation:** branches/files/permissions/policies now use `list(object)` with stable keys, uniqueness checks, and preconditions for repository defaulting.
- **Policy scope fixes:** match_type validation plus DefaultBranch scope handling (repository_id/repository_ref optional) and tightened policy-specific rules.
- **Outputs/docs/tests:** new map-based outputs for branches/files/permissions/policies, updated import guide, examples, fixtures, unit tests, and terratest scenarios; removed deprecated check_credentials policy support to avoid provider warnings.
- **DefaultBranch scoping:** branch policies now default to the module repository when match_type is DefaultBranch to avoid project-wide policy conflicts.
