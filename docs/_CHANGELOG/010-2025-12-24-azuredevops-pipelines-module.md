# Filename: 010-2025-12-24-azuredevops-pipelines-module.md

# 010. Azure DevOps Pipelines module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_pipelines/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-007

---

## Key Changes

- **New module:** added `modules/azuredevops_pipelines` with Azure DevOps provider `1.12.2` for build definitions.
- **Folders + permissions:** implemented build folders and permission resources with per-item inputs.
- **Authorizations:** added pipeline and resource authorizations to control access.
- **Examples:** added basic, complete, and secure examples for YAML pipelines.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding for AZDO pipelines.
