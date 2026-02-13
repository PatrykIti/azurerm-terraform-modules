# TASK-ADO-024: Azure DevOps Service Hooks Module Refactor
# FileName: TASK-ADO-024_AzureDevOps_ServiceHooks_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_servicehooks` has most refactor goals implemented (stable permission keys, validations, sensitive handling).
This re-open captures remaining scope/semantics decisions and release/test closure.

## Current State (Already Aligned)

- Single-object inputs for webhook/storage queue hooks (not list-index iteration).
- Permissions use stable key-based `for_each` and normalized values.
- Event selector and numeric validations are in place.
- Sensitive fields are marked sensitive.
- `docs/IMPORT.md` exists.

## Remaining Gaps

- Scope semantics decision is still ambiguous:
  - Module currently allows creating both webhook and storage queue hooks in one module instance.
  - Module description suggests a single subscription pattern and needs explicit rule (allow both vs enforce exactly one).
- Release/tag mismatch remains:
  - `module.json` prefix is `ADOSHv`, while root docs link legacy `ADOSH1.0.0`.
  - Example refs use `ADOSHv1.0.0`, which is currently missing as a git tag.
- Final closure artifacts are missing (scope/coverage report + explicit decision rationale).

## Scope

- Module: `modules/azuredevops_servicehooks/`
- Examples: `modules/azuredevops_servicehooks/examples/*`
- Tests: `modules/azuredevops_servicehooks/tests/*`
- Docs: module README, module description, root release/version references

## Docs to Update

- `modules/azuredevops_servicehooks/README.md`
- `modules/azuredevops_servicehooks/module.json`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Scope decision:** explicitly choose and enforce one rule:
  - allow both webhook + storage queue together, or
  - enforce exactly one hook type per module instance.
- **Validation/docs sync:** implement validation and documentation to match chosen rule.
- **Release normalization:** align tags/references via `TASK-ADO-039` (`ADOSHv*`).
- **Test harness/coverage:** ensure tests cover chosen scope rule and remain consistent with `TASK-ADO-041`.

## Acceptance Criteria

- Scope rule is explicit, documented, and enforced in code.
- Docs/examples point to existing `ADOSHv*` release tags.
- Test suite includes positive/negative coverage for scope rule.
- Final status report for scope/coverage closure is attached.

## Implementation Checklist

- [ ] Decide and document module-level hook scope semantics.
- [ ] Update variable validation and tests for chosen semantics.
- [ ] Publish/confirm `ADOSHv*` release and update references.
- [ ] Add closure report with status summary and residual risks.
