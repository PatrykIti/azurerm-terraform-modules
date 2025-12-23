# Filename: 004-2025-12-23-azuredevops-identity-module.md

# 004. Azure DevOps Identity module

**Date:** 2025-12-23  
**Type:** Feature  
**Scope:** `modules/azuredevops_identity/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-002

---

## Key Changes

- **New module:** added `modules/azuredevops_identity` with Azure DevOps provider `1.12.2` and identity resources.
- **Identity controls:** implemented groups, memberships, entitlements, and security role assignments.
- **Examples:** added basic, complete, and secure examples tailored to Azure DevOps identity use cases.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding to use AZDO env variables and identity-specific scenarios.
- **Docs:** refreshed module security guidance and task tracking.
