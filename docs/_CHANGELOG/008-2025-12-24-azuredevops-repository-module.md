# Filename: 008-2025-12-24-azuredevops-repository-module.md

# 008. Azure DevOps Repository module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_repository/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-006

---

## Key Changes

- **New module:** added `modules/azuredevops_repository` with Azure DevOps provider `1.12.2` for Git repositories.
- **Repository management:** implemented repositories, branches, files, and git permissions with repository key mapping.
- **Policies:** added branch and repository policy resources with scoped inputs.
- **Examples:** added basic, complete, and secure examples for repository workflows.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding for AZDO project contexts.
- **Docs:** refreshed security guidance and task tracking.
