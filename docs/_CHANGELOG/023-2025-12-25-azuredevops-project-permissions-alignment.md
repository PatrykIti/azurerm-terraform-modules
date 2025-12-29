# Filename: 023-2025-12-25-azuredevops-project-permissions-alignment.md

# 023. Azure DevOps Project Permissions module – alignment & verification

**Date:** 2025-12-25  
**Type:** Maintenance / Verification  
**Scope:** `modules/azuredevops_project_permissions/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-015

---

## Key Changes

- **Examples/Fixtures:** added explicit `required_providers` for `microsoft/azuredevops`.
- **Tests:** aligned `Makefile`, scripts, and README with TESTING_GUIDE, including log output under `test_outputs/`.
- **Validation/Docs:** fixed `trimspace` validations and refreshed README/SECURITY references.
