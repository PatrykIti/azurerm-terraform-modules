# TASK-ADO-041: Azure DevOps Test Harness Consistency Alignment
# FileName: TASK-ADO-041_AzureDevOps_Test_Harness_Consistency_Alignment.md

**Priority:** 🟡 Medium  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** docs/TESTING_GUIDE/README.md, docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md (Go Tests + Fixtures addendum), `modules/azuredevops_repository/tests` baseline  
**Status:** 🟢 Done (2026-02-14)

---

## Overview

Unify Go test patterns and `tests/Makefile` conventions across all `modules/azuredevops_*` so test execution, logging, and CI behavior are predictable and aligned with repo standards.

## Completion Summary (2026-02-14)

- Added missing `t.Parallel()` in outlier suites:
  - `modules/azuredevops_pipelines/tests/azuredevops_pipelines_test.go`
  - `modules/azuredevops_extension/tests/azuredevops_extension_test.go`
- Removed placeholder performance test pattern by converting to disabled benchmark style:
  - `modules/azuredevops_project_permissions/tests/performance_test.go`
- Normalized target contract for outlier harnesses:
  - added `test-validation` to `modules/azuredevops_agent_pools/tests/Makefile`
  - added `test-validation` to `modules/azuredevops_elastic_pool/tests/Makefile`
- Aligned script/config coverage for validation target:
  - `modules/azuredevops_agent_pools/tests/run_tests_parallel.sh`
  - `modules/azuredevops_agent_pools/tests/run_tests_sequential.sh`
  - `modules/azuredevops_elastic_pool/tests/run_tests_parallel.sh`
  - `modules/azuredevops_elastic_pool/tests/run_tests_sequential.sh`
  - `modules/azuredevops_agent_pools/tests/test_config.yaml`
  - `modules/azuredevops_elastic_pool/tests/test_config.yaml`
- Updated test docs for outlier modules:
  - `modules/azuredevops_agent_pools/tests/README.md`
  - `modules/azuredevops_elastic_pool/tests/README.md`

## Scope

- All `modules/azuredevops_*/tests/` directories.
- Files: `*.go`, `Makefile`, `test_config.yaml`, `test_env.sh`, `run_tests_parallel.sh`, `run_tests_sequential.sh`, `tests/README.md`.

## Acceptance Criteria

- No Azure DevOps module test suite relies on placeholder/not-implemented test bodies. ✅
- `t.Parallel()` and stage patterns are consistent with agreed baseline. ✅
- `tests/Makefile` exposes a consistent target contract (`test`, `test-basic`, `test-complete`, `test-secure`, `test-validation`, `test-integration`, `clean`, `validate-fixtures`, `fmt-check`). ✅
- Required env vars are clearly documented and consistent across test files/config. ✅
- Audit addendum checks for Go Tests + Fixtures pass for all `azuredevops_*` modules. ✅

## Verification Evidence

- Static checks:
  - no missing `t.Parallel()` in `azuredevops_*_test.go` suites (count parity check)
  - no placeholder performance test phrases (`not implemented`) in `modules/azuredevops_*/tests/*.go`
  - no missing required targets in any `modules/azuredevops_*/tests/Makefile`
  - no missing `ValidationRules` entries in `run_tests_parallel.sh` / `run_tests_sequential.sh`
- Compile gate:
  - `for d in modules/azuredevops_*/tests; do (cd "$d" && go test ./... -run '^$'); done` -> PASS for all modules.
  - Evidence log: `/tmp/task_ado_041_checks_20260214_215239.log`

## Implementation Checklist

- [x] Define canonical Azure DevOps test harness baseline (`repository` or other agreed module).
- [x] Patch outlier Go tests (`pipelines`, `extension`, `project_permissions` and any additional outliers).
- [x] Normalize `tests/Makefile` and script contracts across modules.
- [x] Sync env var requirements across docs/scripts/configs.
- [x] Run compile gate and static consistency checks.
- [x] Update task board + changelog references as needed.
