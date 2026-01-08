# Filename: 056-2026-01-09-azuredevops-user-entitlement-compliance-fixes.md

# 056. Azure DevOps User Entitlement module compliance fixes

**Date:** 2026-01-09  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_user_entitlement/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-038

---

## Key Changes

- Refactored the module to manage a single user entitlement (no `for_each` on the main resource) with updated outputs.
- Strengthened selector and license/source validations and documented derived key behavior.
- Refreshed examples, fixtures, and unit/Terratest suites to match the new interface.
- Updated module/docs READMEs, import guidance, and task/changelog indexes.
