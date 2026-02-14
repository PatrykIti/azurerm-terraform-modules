# TASK-ADO-023: Azure DevOps Repository Module Refactor
# FileName: TASK-ADO-023_AzureDevOps_Repository_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-006
**Status:** ✅ **Done** (re-verified 2026-02-14)

---

## Overview

Refactor/align `modules/azuredevops_repository` with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES: single primary repository resource, stable addressing for children/policies, validated initialization rules, and complete docs/tests gate.

## Completion Summary

- Primary resource is single and non-iterated:
  - `azuredevops_git_repository.git_repository`
- Flat repository API and validated initialization semantics are implemented:
  - supports `Uninitialized|Clean|Import`
  - Import path validation for source/auth combinations.
- Child resources use stable key maps (branches/files/permissions/policy collections).
- Module-owned repository wiring is consistent for child resources and policy scopes.
- Outputs expose repository identity plus stable maps for branches/files/permissions/policies.
- Docs/examples/tests are aligned with current interface and policy structure.

## Verification Evidence (2026-02-14)

Full module gate executed successfully:
- module `init` + `validate`
- examples `basic|complete|secure` `init` + `validate`
- `terraform test -test-directory=tests/unit`
- integration compile: `go test -c -run 'Test.*Integration' ./...` in `modules/azuredevops_repository/tests`

Evidence log:
- `/tmp/task_ado_023_checks_20260214_231030.log`

## Acceptance Criteria

- Module aligns with MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (stable keys, validated cross-references). ✅
- Repository initialization rules are enforced and tested. ✅
- Branch/policy resources use stable, human-readable keys and outputs. ✅
- Examples/docs/tests remain aligned and passing gate checks. ✅

## Implementation Checklist

- [x] Flat single-repository API and initialization validations.
- [x] Stable map-driven addressing for branches/files/permissions/policies.
- [x] Repository-scoped policy/resource wiring consistency.
- [x] Outputs and documentation alignment.
- [x] Unit/integration-compile gate passed with evidence.
