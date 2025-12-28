# Filename: 043-2025-12-28-ado-pipelines-refactor.md

# 043. Azure DevOps Pipelines module - refactor alignment

**Date:** 2025-12-28  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_pipelines/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-021

---

## Key Changes

- **Single build definition:** refactored inputs to a single build definition with module-level for_each for multiples.
- **Stable list keys:** list inputs now use stable key defaults and uniqueness validation.
- **Validation & defaults:** tightened validation for IDs/types and defaulted authorizations to the module pipeline.
- **Docs & examples:** updated usage, examples, import docs, and outputs to reflect new inputs.
- **Tests aligned:** unit tests, fixtures, and terratest updated for the new schema.
