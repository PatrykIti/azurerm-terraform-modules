# Filename: 033-2025-12-26-azuredevops-pipelines-refactor.md

# 033. Azure DevOps Pipelines module – refactor & alignment

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_pipelines/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-021

---

## Key Changes

- **Stable list keys:** added optional `key` fields and uniqueness validation for folders, permissions, and authorizations.
- **Stricter validation:** enforced required identifiers and key references for pipeline/resource authorizations and build definition permissions.
- **Outputs updated:** build folder outputs now use stable, human-readable keys.
- **Docs & examples:** fixed-name examples, added `docs/IMPORT.md`, refreshed README via terraform-docs.
- **Tests aligned:** fixtures, unit tests, and scripts updated to follow TESTING_GUIDE conventions.
