# TASK-ADO-025: Azure DevOps Variable Groups Module Refactor
# FileName: TASK-ADO-025_AzureDevOps_Variable_Groups_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-039, TASK-ADO-041
**Status:** 🟠 **Re-opened**

---

## Overview

`modules/azuredevops_variable_groups` still mixes atomic scopes and requires strict boundary alignment.

## Mandatory Rule (Atomic Boundary)

- Primary resource in a module must be single and non-iterated (`no for_each`, `no count` on primary block).
- Additional resources may remain only when they are strict children of that primary resource.
- Strict child means direct dependency on module-managed primary resource and no external-ID fallback.
- If a resource can operate without module primary resource (for example via external `*_id` input), it must be moved to a separate atomic module.
- Multiplicity belongs in consumer configuration via module-level `for_each`.

## Current Gaps

- `azuredevops_library_permissions` is independent from `azuredevops_variable_group` and should be split.
- `azuredevops_variable_group_permissions` accepts external `variable_group_id` fallback, so it is not strict-child only.
- Existing validation hardening still needs completion for permissions map semantics.
- Release references still require `ADOVGv*` normalization (`TASK-ADO-039`).

## Scope

- Module: `modules/azuredevops_variable_groups/`
- Examples: `modules/azuredevops_variable_groups/examples/*`
- Tests: `modules/azuredevops_variable_groups/tests/*`
- Docs: module README + root release/version references

## Docs to Update

- `modules/azuredevops_variable_groups/README.md`
- `modules/azuredevops_variable_groups/docs/README.md`
- `README.md`
- `docs/_TASKS/README.md`

## Work Items

- **Atomic split:** move `library_permissions` to dedicated atomic module.
- **Strict-child cleanup:** either remove external `variable_group_id` fallback from this module or split variable-group permissions to dedicated module.
- **Validation hardening:** enforce non-empty permissions maps and allowed values.
- **Tests/examples:** update for new composition pattern and negative validation coverage.
- **Release normalization:** align tags and links with `ADOVGv*` (`TASK-ADO-039`).

## Acceptance Criteria

- No independent permissions scope remains in this module.
- Any retained permission resource is strict-child only.
- Permissions validation is explicit and covered by negative tests.
- Examples show composition for split permission modules.
- Docs reference existing `ADOVGv*` release tags.

## Implementation Checklist

- [ ] Split `library_permissions` into dedicated module.
- [ ] Remove fallback-based non-child behavior from retained resources.
- [ ] Add/verify permissions map validations and tests.
- [ ] Update examples/docs for composition model.
- [ ] Publish/confirm `ADOVGv*` release and fix references.
