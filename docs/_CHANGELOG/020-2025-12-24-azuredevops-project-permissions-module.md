# Filename: 020-2025-12-24-azuredevops-project-permissions-module.md

# 020. Azure DevOps Project Permissions module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_project_permissions/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-001

---

## Key Changes

- **New module:** added `modules/azuredevops_project_permissions` with Azure DevOps provider `1.12.2` for project permission assignments.
- **Lookup support:** permissions can resolve group principals via `group_name` + `scope` with `principal` override.
- **Examples:** added basic, complete, and secure examples for project and collection scope groups.
- **Tests:** added fixtures, unit tests, and Terratest scaffolding for permissions.
