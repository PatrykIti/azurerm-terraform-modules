# TASK-ADO-027: Azure DevOps Team Module Refactor
# FileName: TASK-ADO-027_AzureDevOps_Team_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-003
**Status:** 🟡 **To Do**

---

## Overview

Refactor `modules/azuredevops_team` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys, stronger cross-field validation, and missing import docs.
Document any deviations required by provider constraints.

## Scope (Provider Resources)

- `azuredevops_team`
- `azuredevops_team_members`
- `azuredevops_team_administrators`

## Current Gaps (Summary)

- `team_members` and `team_administrators` use index-based `for_each`, producing unstable addresses.
- Outputs for memberships/admins are keyed by index rather than stable keys.
- No `key` inputs or uniqueness validation for membership/admin lists.
- No validation that `team_key` references exist in `teams`.
- `mode` defaults to `null` instead of explicit `add`.
- Missing `docs/IMPORT.md` for the module.
- Examples use random/dynamic names instead of fixed names.

## Target Module Design

### Inputs (Teams)

Keep `teams` map(object) schema, add validation:
- Team key and name must be non-empty strings (when provided).

### Inputs (Team Members)

`team_members` (list(object)):
- key (optional string) for stable `for_each`
- team_id (optional string)
- team_key (optional string)
- member_descriptors (list(string))
- mode (optional string, default "add")

Validation rules:
- Exactly one of `team_id` or `team_key`.
- `team_key` must exist in `teams`.
- `member_descriptors` must be non-empty.
- Unique for_each keys using `coalesce(key, team_id, team_key)`.
- `mode` must be one of `add` or `overwrite`.

### Inputs (Team Administrators)

`team_administrators` (list(object)):
- key (optional string)
- team_id (optional string)
- team_key (optional string)
- admin_descriptors (list(string))
- mode (optional string, default "add")

Validation rules:
- Exactly one of `team_id` or `team_key`.
- `team_key` must exist in `teams`.
- `admin_descriptors` must be non-empty.
- Unique for_each keys using `coalesce(key, team_id, team_key)`.
- `mode` must be one of `add` or `overwrite`.

### Locals / Implementation

- Normalize `team_members` and `team_administrators` into maps keyed by derived key for stable `for_each`.
- Resolve `team_id` via `local.team_ids` when `team_key` is used.
- Default `mode` to `add` when not set.
- Use `distinct()` on descriptor lists to avoid duplicates (optional).

### Outputs

- `team_ids` and `team_descriptors` (unchanged, use `try()`).
- `team_member_ids` keyed by membership key.
- `team_administrator_ids` keyed by admin key.

## Examples

Update examples for stable keys and fixed names:
- basic: single team + optional members (with `key`).
- complete: multiple teams + members + admins with keys.
- secure: explicit `mode = "overwrite"` for admins.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - Unique key validation for members/admins.
  - `team_key` reference validation.
  - `mode` default and allowed values.
  - Non-empty team name/key validation.
- Integration:
  - Create team + members + admins; validate stable output keys.
- Negative:
  - Unknown `team_key`.
  - Duplicate derived keys.
  - `team_id` and `team_key` both set.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-team-refactor.md`
- Module README + examples + `docs/IMPORT.md`

## Acceptance Criteria

- No index-based `for_each` for membership/admin resources.
- Cross-field validations cover `team_key` references and selector rules.
- Outputs are keyed by stable, human-readable keys and use `try()`.
- Examples use fixed names and demonstrate the new key inputs.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Update `variables.tf`: add `key` fields, add validations, default `mode`.
- [ ] Update `main.tf`: add locals for key normalization, stable `for_each`.
- [ ] Update `outputs.tf`: stable key maps with `try()`.
- [ ] Add `docs/IMPORT.md` and update module README/examples.
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] Run docs generation and update README.
