# Filename: 091-2026-02-14-ado-test-harness-consistency-alignment.md

# 091. Azure DevOps test harness consistency alignment

**Date:** 2026-02-14  
**Type:** Maintenance / Documentation  
**Scope:** `modules/azuredevops_*/tests/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-041

---

## Key Changes

- Added missing `t.Parallel()` calls in outlier suites:
  - `modules/azuredevops_pipelines/tests/azuredevops_pipelines_test.go`
  - `modules/azuredevops_extension/tests/azuredevops_extension_test.go`
- Replaced placeholder performance test body with disabled benchmark pattern in:
  - `modules/azuredevops_project_permissions/tests/performance_test.go`
- Standardized target contract in test Makefiles by adding `test-validation` for:
  - `modules/azuredevops_agent_pools/tests/Makefile`
  - `modules/azuredevops_elastic_pool/tests/Makefile`
- Aligned validation-pattern coverage in helper scripts and config files for the same modules:
  - `run_tests_parallel.sh`, `run_tests_sequential.sh`, `test_config.yaml`, `tests/README.md`
- Ran compile-only Go gate across all Azure DevOps test suites:
  - `go test ./... -run '^$'` in every `modules/azuredevops_*/tests` directory (PASS).

## Board Updates

- `TASK-ADO-041` moved from **To Do** to **Done** in `docs/_TASKS/README.md`.
- Task statistics updated accordingly.
