# TASK-ADO-041: Azure DevOps Test Harness Consistency Alignment
# FileName: TASK-ADO-041_AzureDevOps_Test_Harness_Consistency_Alignment.md

**Priority:** 🟡 Medium  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** docs/TESTING_GUIDE/README.md, docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md (Go Tests + Fixtures addendum), `modules/azuredevops_repository/tests` baseline  
**Status:** 🟡 To Do

---

## Overview

Unify Go test patterns and `tests/Makefile` conventions across all `modules/azuredevops_*` so test execution, logging, and CI behavior are predictable and aligned with repo standards.

## Current Gaps

- `t.Parallel()` is missing in key test suites (for example `modules/azuredevops_pipelines/tests/azuredevops_pipelines_test.go`, `modules/azuredevops_extension/tests/azuredevops_extension_test.go`).
- Placeholder performance test remains in `modules/azuredevops_project_permissions/tests/performance_test.go:10`.
- `tests/Makefile` conventions are inconsistent between modules (for example shell declaration, `TF_CLI_ARGS_init` usage, target defaults/env guards differ between modules).
- Module-level required env checks vary in undocumented ways (`AZDO_PROJECT_ID` required in some modules, omitted in others) and need explicit per-module rationale in `tests/README.md` + `test_config.yaml`.

## Scope

- All `modules/azuredevops_*/tests/` directories.
- Files: `*.go`, `Makefile`, `test_config.yaml`, `test_env.sh`, `run_tests_parallel.sh`, `run_tests_sequential.sh`, `tests/README.md`.

## Docs to Update

### In-Module
- `modules/azuredevops_*/tests/README.md`
- `modules/azuredevops_*/tests/test_config.yaml`

### Repo-Level
- `docs/_TASKS/README.md`
- `docs/TESTING_GUIDE/*` (only if baseline changes are introduced)

## Work Items

- **Go tests:** enforce `t.Parallel()` in non-conflicting tests, keep `testing.Short()` behavior in integration/performance, remove placeholder performance test patterns.
- **Makefile baseline:** normalize headers/targets/logging style to `azuredevops_repository` baseline (or agreed canonical baseline) and keep module-specific env guards explicit.
- **Execution scripts:** align parallel/sequential scripts and config schema so CI orchestration is consistent.
- **Env contract:** document required env vars per module and keep them synchronized between `Makefile`, `test_env.sh`, `test_config.yaml`, and `tests/README.md`.
- **Quality gate:** run compile-only `go test ./... -run '^$'` and validate script/target parity across modules.

## Acceptance Criteria

- No Azure DevOps module test suite relies on placeholder/not-implemented test bodies.
- `t.Parallel()` and stage patterns are consistent with agreed baseline.
- `tests/Makefile` exposes a consistent target contract (`test`, `test-basic`, `test-complete`, `test-secure`, `test-validation`, `test-integration`, `clean`, `validate-fixtures`, `fmt-check`).
- Required env vars are clearly documented and consistent across test files/config.
- Audit addendum checks for Go Tests + Fixtures pass for all `azuredevops_*` modules.

## Implementation Checklist

- [ ] Define canonical Azure DevOps test harness baseline (`repository` or other agreed module).
- [ ] Patch outlier Go tests (`pipelines`, `extension`, `project_permissions` and any additional outliers).
- [ ] Normalize `tests/Makefile` and script contracts across modules.
- [ ] Sync env var requirements across docs/scripts/configs.
- [ ] Run compile gate and static consistency checks.
- [ ] Update task board + changelog references as needed.
