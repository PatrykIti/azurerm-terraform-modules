# Filename: 089-2026-02-14-ado-atomic-realignment-wave2.md

# 089. Azure DevOps atomic realignment wave 2 (serviceendpoint/servicehooks/variable_groups/team/wiki)

**Date:** 2026-02-14  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_serviceendpoint/*`, `modules/azuredevops_servicehooks/*`, `modules/azuredevops_variable_groups/*`, `modules/azuredevops_team/*`, `modules/azuredevops_wiki/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-022, TASK-ADO-024, TASK-ADO-025, TASK-ADO-027, TASK-ADO-040, TASK-ADO-039 (in progress)

---

## Key Changes

- Enforced atomic-boundary model across five Azure DevOps modules by keeping one non-iterated primary resource per module.
- Removed or constrained non-child scopes (external-ID fallback and independent resource families) to strict-child-only behavior.
- Updated examples to local module sources to keep validation/tests runnable before release tag normalization is completed.
- Aligned unit tests, fixtures, and integration compile checks with new module interfaces.
- Refreshed task board state: `TASK-ADO-022/024/025/027/040` moved to done, `TASK-ADO-039` stays in progress pending `v`-tag publication and release pipeline closure.

## Release-Tag Policy Note

- Legacy non-`v` tags remain historical (`ADOPI1.0.0`, `ADOSE1.0.0`, `ADOSH1.0.0`, `ADOT1.0.0`, `ADOVG1.0.0`, `ADOWI1.0.0`, `ADOWK1.0.0`).
- Normalization target remains `tag_prefix + vX.Y.Z` for next releases and is tracked under `TASK-ADO-039`.
