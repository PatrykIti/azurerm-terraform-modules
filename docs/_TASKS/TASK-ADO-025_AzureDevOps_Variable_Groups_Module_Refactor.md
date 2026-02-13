# TASK-ADO-025: Azure DevOps Variable Groups Module Refactor
# FileName: TASK-ADO-025_AzureDevOps_Variable_Groups_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_variable_groups` already follows the single-variable-group model with stable permission keys.
This re-open tracks residual validation hardening, release/tag normalization, and formal compliance closure.

## Current State (Already Aligned)

- Main `azuredevops_variable_group` is single-instance with flat inputs.
- `key_vault` is modeled as a single optional object.
- Permissions use stable keys (`coalesce(key, principal)`).
- Single outputs (`variable_group_id`, `variable_group_name`) are present.
- `docs/IMPORT.md` exists.

## Remaining Gaps

- Permission validation hardening is incomplete:
  - no explicit validation that permission maps are non-empty,
  - no explicit validation that permission values are limited to `Allow|Deny|NotSet`.
- Release/tag mismatch remains:
  - `module.json` prefix is `ADOVGv`, while root docs link `ADOVG1.0.0`.
  - Example refs use `ADOVGv1.0.0`, which is currently missing as a git tag.
- Final closure artifacts are missing (scope/coverage status report and matrix).

## Scope

- Module: `modules/azuredevops_variable_groups/`
- Examples: `modules/azuredevops_variable_groups/examples/*`
- Tests: `modules/azuredevops_variable_groups/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_variable_groups/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Validation hardening:** add permission map non-empty + allowed-value validations for `variable_group_permissions` and `library_permissions`.
- **Test updates:** add negative unit/integration coverage for invalid permission maps/values.
- **Release normalization:** align this module with `TASK-ADO-039` (`ADOVGv*` tags and refs).
- **Compliance closure:** add scope/coverage status summary + matrix.

## Acceptance Criteria

- Permissions are explicitly validated for non-empty map and allowed status values.
- Tests cover negative permission-value and empty-permissions scenarios.
- Docs/examples point to existing `ADOVGv*` release tags.
- Closure report is attached and no High findings remain.

## Implementation Checklist

- [ ] Add missing permission validations in `variables.tf`.
- [ ] Extend tests for permission validation paths.
- [ ] Publish/confirm `ADOVGv*` release and update references.
- [ ] Add final status report + coverage matrix.
