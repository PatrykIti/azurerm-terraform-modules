# TASK-ADO-021: Azure DevOps Pipelines Module Refactor
# FileName: TASK-ADO-021_AzureDevOps_Pipelines_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_pipelines` was already refactored to a single main build definition with stable-key list resources.
This re-open focuses on residual gaps: release/tag alignment, test harness consistency, and final compliance closure.

## Current State (Already Aligned)

- Main `azuredevops_build_definition` is single-instance in-module.
- List resources (`build_folders`, permissions, authorizations) use stable key maps.
- Key uniqueness and cross-field validations are implemented.
- `docs/IMPORT.md` exists.

## Remaining Gaps

- Release/tag mismatch remains for this module:
  - `module.json` tag prefix is `ADOPIv`, but published release references in root docs still point to `ADOPI1.0.0`.
  - Example refs use `ADOPIv1.0.0`, which is not currently present as a git tag.
- Go test consistency gap: core module tests are missing `t.Parallel()` in main suite file.
- Final scope/coverage report from `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md` is not attached as closure artifact.

## Scope

- Module: `modules/azuredevops_pipelines/`
- Examples: `modules/azuredevops_pipelines/examples/*`
- Tests: `modules/azuredevops_pipelines/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_pipelines/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Release normalization:** align this module with `TASK-ADO-039` and publish/point to `ADOPIv*` release tags.
- **Examples alignment:** ensure example `source` refs point to existing `ADOPIv*` release tags.
- **Test harness consistency:** align Go tests and test orchestration conventions with `TASK-ADO-041` baseline (including `t.Parallel()` where safe).
- **Compliance closure:** attach final status report (Scope Status / Provider Coverage Status / Overall Status + matrix).

## Acceptance Criteria

- Root and module docs reference an existing `ADOPIv*` release tag.
- Pipelines examples are runnable against existing release tag(s).
- Go tests for this module follow agreed consistency baseline.
- Compliance closure report is present and no High unresolved findings remain.

## Implementation Checklist

- [ ] Publish/confirm `ADOPIv*` release and update references.
- [ ] Update examples to valid release refs.
- [ ] Patch remaining test harness inconsistencies (`t.Parallel`, orchestration parity).
- [ ] Add final scope/coverage status report for module closure.
