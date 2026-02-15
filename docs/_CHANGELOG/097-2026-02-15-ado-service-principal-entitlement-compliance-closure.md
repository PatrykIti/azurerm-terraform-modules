# Filename: 097-2026-02-15-ado-service-principal-entitlement-compliance-closure.md

# 097. Azure DevOps service principal entitlement compliance closure

**Date:** 2026-02-15  
**Type:** Maintenance / Documentation  
**Scope:** `modules/azuredevops_service_principal_entitlement/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-036

---

## Key Changes

- Closed `TASK-ADO-036` after full re-audit of `modules/azuredevops_service_principal_entitlement`.
- Verified module already meets core compliance expectations:
  - single primary resource (no internal `for_each`),
  - complete fixtures and unit-test set,
  - Terratest suite + helper/orchestration alignment.
- Updated examples to local module source (`../../`) for local validation workflow consistency.
- Regenerated example docs (`terraform-docs` injected sections) after source update.
- Executed full module gate and captured evidence.
- Updated task board:
  - moved `TASK-ADO-036` from **To Do** to **Done**,
  - refreshed task counters.

## Evidence

- Validation/test log: `/tmp/task_ado_036_checks_20260215_212920.log`
