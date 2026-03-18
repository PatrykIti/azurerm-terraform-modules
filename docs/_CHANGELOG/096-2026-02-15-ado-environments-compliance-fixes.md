# Filename: 096-2026-02-15-ado-environments-compliance-fixes.md

# 096. Azure DevOps environments compliance fixes

**Date:** 2026-02-15  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_environments/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-034

---

## Key Changes

- Completed `TASK-ADO-034` for `modules/azuredevops_environments`.
- Refactored checks model:
  - root `check_*` inputs now target only `azuredevops_environment`,
  - nested `kubernetes_resources[*].checks` now target the backing service endpoint.
- Added nested check support for all check resources:
  - approvals, branch control, business hours, exclusive lock, required template, rest API.
- Enforced stable addressing with explicit `name` keys and nested `resource_name:check_name` keys.
- Updated outputs to include grouped check IDs under:
  - `check_ids.environment`
  - `check_ids.kubernetes_resources[resource_name]`
- Updated and aligned:
  - examples (`basic`, `complete`, `secure`) with local source and nested checks,
  - fixtures + unit tests,
  - module docs (`README.md`, `docs/README.md`, `docs/IMPORT.md`, `SECURITY.md`, `VERSIONING.md`).
- Cleaned module terraform artifacts from VCS scope (`.terraform/`, `.terraform.lock.hcl`).
- Updated task board:
  - moved `TASK-ADO-034` from **To Do** to **Done**,
  - refreshed task counters.

## Evidence

- Validation/test log: `/tmp/task_ado_034_checks_20260215_212259.log`
