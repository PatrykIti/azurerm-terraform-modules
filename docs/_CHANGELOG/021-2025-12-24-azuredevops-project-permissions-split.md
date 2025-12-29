# Filename: 021-2025-12-24-azuredevops-project-permissions-split.md

# 021. Azure DevOps Project module - permissions split

**Date:** 2025-12-24  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_project/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-001

---

## Key Changes

- **Breaking:** removed project permissions from `modules/azuredevops_project`.
- **Separation:** moved permission management to the new `modules/azuredevops_project_permissions` module.
- **Docs:** updated examples, security notes, and import guidance for the split.
