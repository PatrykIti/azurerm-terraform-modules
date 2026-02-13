# TASK-ADO-027: Azure DevOps Team Module Refactor
# FileName: TASK-ADO-027_AzureDevOps_Team_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_team` already implements single-team model with stable membership/admin keys.
This re-open focuses on release/tag normalization and final audit closure.

## Current State (Already Aligned)

- Single `azuredevops_team` resource with flat team inputs.
- `team_members` and `team_administrators` use stable key maps.
- Mode defaults and allowed-value validations are implemented.
- Stable output maps are present.
- `docs/IMPORT.md` exists.

## Remaining Gaps

- Release/tag mismatch remains:
  - `module.json` prefix is `ADOTv`, while root docs link `ADOT1.0.0`.
  - Example refs use `ADOTv1.0.0`, which is currently missing as a git tag.
- Final closure artifact is missing:
  - need attached status report and capability matrix for this module.
- Minor test-harness consistency checks should be aligned with ADO baseline (`TASK-ADO-041`) before closure.

## Scope

- Module: `modules/azuredevops_team/`
- Examples: `modules/azuredevops_team/examples/*`
- Tests: `modules/azuredevops_team/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_team/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Release normalization:** align to `TASK-ADO-039` and publish/point to existing `ADOTv*` tag.
- **Examples/docs alignment:** ensure all source refs and version links use existing `ADOTv*` release tag.
- **Closure report:** attach scope/provider/overall status and concise matrix.
- **Test consistency:** verify no remaining harness drift relative to common ADO test baseline.

## Acceptance Criteria

- Docs/examples reference existing `ADOTv*` release tag(s).
- Compliance closure report is attached with no unresolved High findings.
- Test harness is aligned with ADO baseline requirements.

## Implementation Checklist

- [ ] Publish/confirm `ADOTv*` release and update references.
- [ ] Verify and update example/source version refs.
- [ ] Attach final scope/coverage status report.
- [ ] Confirm test harness parity with baseline.
