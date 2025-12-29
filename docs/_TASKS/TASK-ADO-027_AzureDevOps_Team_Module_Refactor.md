# TASK-ADO-027: Azure DevOps Team Module Refactor
# FileName: TASK-ADO-027_AzureDevOps_Team_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-003
**Status:** 🟠 **Re-opened**

---

## Overview

Refactor `modules/azuredevops_team` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys, stronger cross-field validation, and missing import docs.
Document any deviations required by provider constraints.
The main `azuredevops_team` must be a single (non-iterated) resource with flat inputs; for multiple teams use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_team`
- `azuredevops_team_members`
- `azuredevops_team_administrators`

## Current Gaps (Summary)

- `teams` are modeled as a map and iterated; should be a single team resource with flat inputs and module-level `for_each`.
- `team_members` and `team_administrators` use index-based `for_each`, producing unstable addresses.
- Outputs for memberships/admins are keyed by index rather than stable keys.
- No `key` inputs or uniqueness validation for membership/admin lists.
- No validation that team selectors resolve when defaulting to the module team.
- `mode` defaults to `null` instead of explicit `add`.
- Missing `docs/IMPORT.md` for the module.
- Examples use random/dynamic names instead of fixed names.

## Target Module Design

### Inputs (Team)

Flat variables for the main team (single resource). No `teams` map.
Validate required strings as non-empty (e.g., name, project_id).

### Inputs (Team Members)

`team_members` (list(object)):
- key (optional string) for stable `for_each`
- team_id (optional string)
- member_descriptors (list(string))
- mode (optional string, default "add")

Validation rules:
- team_id must be non-empty when provided.
- when team_id is omitted, the module team must be present.
- `member_descriptors` must be non-empty.
- Unique for_each keys using `coalesce(key, team_id)`.
- `mode` must be one of `add` or `overwrite`.

### Inputs (Team Administrators)

`team_administrators` (list(object)):
- key (optional string)
- team_id (optional string)
- admin_descriptors (list(string))
- mode (optional string, default "add")

Validation rules:
- team_id must be non-empty when provided.
- when team_id is omitted, the module team must be present.
- `admin_descriptors` must be non-empty.
- Unique for_each keys using `coalesce(key, team_id)`.
- `mode` must be one of `add` or `overwrite`.

### Locals / Implementation

- Normalize `team_members` and `team_administrators` into maps keyed by derived key for stable `for_each`.
- Default `team_id` to the module team when omitted.
- Default `mode` to `add` when not set.
- Use `distinct()` on descriptor lists to avoid duplicates (optional).

### Outputs

- `team_id` and `team_descriptor`.
- `team_member_ids` keyed by membership key.
- `team_administrator_ids` keyed by admin key.

## Examples

Update examples for stable keys and fixed names:
- basic: single team + optional members (with `key`).
- complete: team + members + admins with keys (show module-level `for_each` for multiple teams).
- secure: explicit `mode = "overwrite"` for admins.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - Unique key validation for members/admins.
  - team_id defaulting/required validation.
  - `mode` default and allowed values.
  - Non-empty team name validation.
- Integration:
  - Create team + members + admins; validate stable output keys.
- Negative:
  - Missing team_id when module team is not created.
  - Duplicate derived keys.
  - Empty team_id values.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-team-refactor.md`
- Module README + examples + `docs/IMPORT.md`

## Acceptance Criteria

- No index-based `for_each` for membership/admin resources.
- Cross-field validations cover team_id defaulting and selector rules.
- Outputs are keyed by stable, human-readable keys and use `try()`.
- Examples use fixed names and demonstrate the new key inputs.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Update `variables.tf`: replace `teams` map with flat team inputs; add `key` fields, validations, default `mode`.
- [ ] Update `main.tf`: add locals for key normalization, stable `for_each`, default team_id to module team.
- [ ] Update `outputs.tf`: single team outputs + stable key maps with `try()`.
- [ ] Add `docs/IMPORT.md` and update module README/examples.
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] Run docs generation and update README.
