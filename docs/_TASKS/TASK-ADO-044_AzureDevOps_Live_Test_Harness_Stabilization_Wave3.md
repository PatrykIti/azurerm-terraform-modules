# TASK-ADO-044: Azure DevOps Live Test Harness Stabilization Wave 3
# FileName: TASK-ADO-044_AzureDevOps_Live_Test_Harness_Stabilization_Wave3.md

**Priority:** 🟡 Medium  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** `TASK-ADO-041`, `docs/TESTING_GUIDE/README.md`, current `modules/azuredevops_*/tests` baseline  
**Status:** 🟢 Done (2026-03-18)

---

## Overview

Stabilize the remaining Azure DevOps Terratest harnesses after repeated CI failures caused by nondeterministic cleanup options and transient Azure DevOps/provider transport errors during live integration runs.

## Completion Summary (2026-03-18)

- Normalized cleanup behavior so deploy and cleanup reuse the same saved `TerraformOptions` when `.test-data/TerraformOptions.json` exists.
- Added retry coverage for known transient Azure DevOps/provider failures:
  - `connection reset by peer`
  - `invalid character '<' looking for beginning of value`
- Applied harness stabilization to:
  - `modules/azuredevops_agent_pools/tests/*`
  - `modules/azuredevops_elastic_pool/tests/*`
  - `modules/azuredevops_environments/tests/*`
  - `modules/azuredevops_extension/tests/*`
  - `modules/azuredevops_group/tests/*`
  - `modules/azuredevops_group_entitlement/tests/*`
  - `modules/azuredevops_service_principal_entitlement/tests/*`
  - `modules/azuredevops_servicehooks/tests/*`
  - `modules/azuredevops_team/tests/*`
  - `modules/azuredevops_variable_groups/tests/*`

## Scope

- Remaining Azure DevOps modules with Terratest suites that still used fresh cleanup options or incomplete retry maps after earlier harness fixes.

## Acceptance Criteria

- Cleanup no longer recreates fresh random Terraform options when saved options are available. ✅
- Retry maps cover known Azure DevOps transient response failures observed in CI. ✅
- Updated Go test harnesses compile cleanly. ✅
- Task board and local changelog reflect the stabilization wave. ✅

## Verification Evidence

- `gofmt -w` run across all changed Azure DevOps test harness files.
- `go test ./...` run in:
  - `modules/azuredevops_project_permissions/tests`
  - `modules/azuredevops_pipelines/tests`
- Static diff hygiene:
  - `git diff --check`

## Implementation Checklist

- [x] Audit remaining Azure DevOps Terratest harnesses for fresh cleanup option usage.
- [x] Patch cleanup to prefer `test_structure.LoadTerraformOptions(...)`.
- [x] Extend retryable error patterns for Azure DevOps/provider transport flakiness.
- [x] Format changed Go files.
- [x] Update task board and local changelog.
