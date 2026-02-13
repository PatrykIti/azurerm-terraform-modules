# TASK-ADO-026: Azure DevOps Work Items Module Refactor
# FileName: TASK-ADO-026_AzureDevOps_Work_Items_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_work_items` already has stable keys and expanded outputs.
This re-open targets unresolved atomic-scope governance, release/tag normalization, and final compliance sign-off.

## Current State (Already Aligned)

- `project_id` defaulting and project-scoped validation patterns are implemented.
- Stable key maps are used for process/query/folder/permission resources.
- Output coverage for folders/queries/permissions is present.
- `docs/IMPORT.md` exists.

## Remaining Gaps

- Atomic-scope decision remains unresolved:
  - module currently manages multiple resource families in one module (`workitem`, `process`, `query_folder`, `query`, and several permissions),
  - needs explicit decision: keep composite scope (with documented rationale) or split into smaller atomic modules.
- Release/tag mismatch remains:
  - `module.json` prefix is `ADOWKv`, while root docs link `ADOWK1.0.0`.
  - Example refs use `ADOWKv1.0.0`, which is currently missing as a git tag.
- Closure artifact missing:
  - no final scope/coverage matrix documenting intentional scope breadth and accepted tradeoffs.

## Scope

- Module: `modules/azuredevops_work_items/`
- Examples: `modules/azuredevops_work_items/examples/*`
- Tests: `modules/azuredevops_work_items/tests/*`
- Docs: module README + scope narrative + root release/version references

## Docs to Update

- `modules/azuredevops_work_items/README.md`
- `modules/azuredevops_work_items/docs/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Scope governance:** decide and record whether current multi-resource scope is accepted or must be split.
- **If split is required:** define migration plan and follow-up tasks for resource decomposition.
- **If scope is retained:** document rationale and explicit boundaries in module docs and coverage matrix.
- **Release normalization:** align with `TASK-ADO-039` (`ADOWKv*` tags and references).
- **Final closure:** attach status report with scope/provider status and action plan.

## Acceptance Criteria

- Explicit decision exists for composite-scope vs split-model direction.
- Module docs match the chosen scope model with no ambiguity.
- Docs/examples reference existing `ADOWKv*` release tags.
- Scope/coverage closure report is attached and approved.

## Implementation Checklist

- [ ] Record formal scope decision (retain or split).
- [ ] Update docs and follow-up tasks according to decision.
- [ ] Publish/confirm `ADOWKv*` release and update references.
- [ ] Attach final status report + coverage matrix.
