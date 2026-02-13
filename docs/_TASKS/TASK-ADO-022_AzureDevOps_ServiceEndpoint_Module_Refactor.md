# TASK-ADO-022: Azure DevOps Service Endpoint Module Refactor
# FileName: TASK-ADO-022_AzureDevOps_ServiceEndpoint_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_serviceendpoint` is already on the new single-endpoint-per-module model with one-of endpoint selection and stable permission keys.
This re-open is for final hardening and release/compliance closure.

## Current State (Already Aligned)

- Single-endpoint model enforced by one-of selector across `serviceendpoint_*` inputs.
- Stable-key permissions map and default target resolution are implemented.
- Strong auth-mode validations and sensitive input handling are present.
- Single outputs (`serviceendpoint_id`, `serviceendpoint_name`) are present.
- `docs/IMPORT.md` exists.

## Remaining Gaps

- Release/tag mismatch remains for this module:
  - `module.json` prefix is `ADOSEv`, but root docs point to legacy `ADOSE1.0.0`.
  - Example refs use `ADOSEv1.0.0`, which is currently missing as a git tag.
- Final coverage closure is missing:
  - Need explicit capability coverage matrix for the broad endpoint/auth combinations against pinned provider version.
- Test consistency should be aligned with common ADO harness baseline from `TASK-ADO-041`.

## Scope

- Module: `modules/azuredevops_serviceendpoint/`
- Examples: `modules/azuredevops_serviceendpoint/examples/*`
- Tests: `modules/azuredevops_serviceendpoint/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_serviceendpoint/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Release normalization:** align to `TASK-ADO-039` and publish/point to existing `ADOSEv*` tag.
- **Coverage closure:** produce and store provider capability matrix for supported endpoint/auth combinations.
- **Test harness alignment:** ensure test/Makefile/script conventions match ADO baseline (`TASK-ADO-041`).
- **Final status report:** add Scope/Provider/Overall status summary and residual-risk notes.

## Acceptance Criteria

- Docs and examples reference existing `ADOSEv*` release tag(s).
- Coverage matrix for module scope exists and documents intentional omissions.
- Test harness is consistent with repository ADO baseline.
- Module closure report shows no unresolved High findings.

## Implementation Checklist

- [ ] Publish/confirm `ADOSEv*` release and update references.
- [ ] Generate capability matrix + closure report.
- [ ] Align tests/scripts to common ADO harness baseline.
- [ ] Close task after evidence is attached in docs.
