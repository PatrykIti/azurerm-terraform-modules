# Filename: 034-2025-12-26-azuredevops-repository-refactor.md

# 034. Azure DevOps Repository module – refactor & alignment

**Date:** 2025-12-26  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_repository/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-023

---

## Key Changes

- **Stable list keys:** added optional `key` fields and stable `for_each` maps for branches, files, permissions, and policies.
- **Repository initialization defaults:** `initialization` is optional with defaults; Import enforces source/auth rules.
- **Stricter validation:** repository key references, scope rules, policy constraints, and permission values are validated.
- **Outputs updated:** branch and policy outputs now use stable, human-readable keys.
- **Docs & tests:** fixed-name examples, refreshed fixtures/unit tests, and added `docs/IMPORT.md`.
