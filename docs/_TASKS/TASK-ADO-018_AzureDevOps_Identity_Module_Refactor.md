# TASK-ADO-018: Azure DevOps Identity Module Refactor
# FileName: TASK-ADO-018_AzureDevOps_Identity_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-002
**Status:** ✅ **Done** (2025-12-28)

---

## Overview

Refactor `modules/azuredevops_identity` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys, stronger cross-field validation, and missing import docs.
Document any deviations required by resource-specific constraints.
The main `azuredevops_group` must be a single (non-iterated) resource with flat inputs; for multiple groups use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_group`
- `azuredevops_group_membership`
- `azuredevops_group_entitlement`
- `azuredevops_user_entitlement`
- `azuredevops_service_principal_entitlement`
- `azuredevops_securityrole_assignment`

## Current Gaps (Summary)

- `azuredevops_group` is iterated via `groups` map; should be a single resource with flat inputs and module-level `for_each`.
- List resources use index-based `for_each` (memberships, entitlements, role assignments), causing unstable addressing.
- Outputs for entitlements and memberships are keyed by index instead of stable keys.
- No validation that group/identity selectors resolve when defaulting to the module group.
- No explicit `key` inputs or uniqueness validation for list resources.
- `group_memberships.mode` defaults to `null` instead of explicit `add`.
- Missing `docs/IMPORT.md` for the module.
- No output for `azuredevops_securityrole_assignment` IDs.

## Target Module Design

### Inputs (Group)

Flat variables for the main group (single resource). No `groups` map.
Include provider-required fields and enforce non-empty validation for required strings.

### Inputs (Group Memberships)

`group_memberships` (list(object)):
- key (optional string) for stable `for_each`
- group_descriptor (optional string) — default to module group descriptor when omitted
- member_descriptors (optional list(string), default [])
- mode (optional string, default "add")

Validation rules:
- At least one member via `member_descriptors`.
- When `group_descriptor` is omitted, the module group must be present.
- `group_descriptor` must be non-empty when provided.
- Unique for_each keys using `coalesce(key, group_descriptor)`; require `key` if multiple entries target the same group.

### Inputs (Entitlements)

`group_entitlements` (list(object)):
- key (optional string)
- display_name (optional string)
- origin (optional string)
- origin_id (optional string)
- account_license_type (optional string, default "express")
- licensing_source (optional string, default "account")

Validation rules:
- Exactly one of `display_name` or (`origin` + `origin_id`).
- Unique keys using `coalesce(key, display_name, origin_id)`.

`user_entitlements` (list(object)):
- key (optional string)
- principal_name (optional string)
- origin (optional string)
- origin_id (optional string)
- account_license_type (optional string, default "express")
- licensing_source (optional string, default "account")

Validation rules:
- Exactly one of `principal_name` or (`origin` + `origin_id`).
- Unique keys using `coalesce(key, principal_name, origin_id)`.

`service_principal_entitlements` (list(object)):
- key (optional string)
- origin_id (string)
- origin (optional string, confirm provider requirement)
- account_license_type (optional string, default "express")
- licensing_source (optional string, default "account")

Validation rules:
- Unique keys using `coalesce(key, origin_id)`.
- Enforce any provider-required `origin` constraints.

### Inputs (Security Role Assignments)

`securityrole_assignments` (list(object)):
- key (optional string)
- scope (string)
- resource_id (string)
- role_name (string)
- identity_id (optional string) — default to module group ID when omitted

Validation rules:
- identity_id must be non-empty when provided.
- When `identity_id` is omitted, the module group must be present.
- Unique keys using `coalesce(key, identity_id, "${scope}/${resource_id}/${role_name}")`.

### Locals / Implementation

- Build normalized maps in `locals` for each list input (memberships, entitlements, assignments).
- Use the normalized maps for `for_each` to ensure stable resource addressing.
- Default `mode` to `add` if unset.
- Consider `distinct()` for membership `members` if duplicates appear in inputs.
- Resolve default group_descriptor/identity_id from the module-created group when omitted.

### Outputs

- `group_id` and `group_descriptor`.
- `group_membership_ids` keyed by membership key.
- `group_entitlement_ids` and `group_entitlement_descriptors` keyed by entitlement key.
- `user_entitlement_ids` and `user_entitlement_descriptors` keyed by entitlement key.
- `service_principal_entitlement_ids` and `service_principal_entitlement_descriptors` keyed by entitlement key.
- `securityrole_assignment_ids` keyed by assignment key (new).

## Examples

Update examples for stable keys and new validations:
- basic: one group.
- complete: group + membership + all entitlements + role assignment (show optional `key`).
- secure: explicit membership `mode = "overwrite"` and minimal entitlements.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - Unique key validation for each list resource.
  - group_descriptor/identity_id defaulting and non-empty validation.
  - Membership mode default (add) and allowed values.
  - Entitlement selector validation (name vs origin + origin_id).
- Integration:
  - Create group + membership + one entitlement type; validate stable output keys.
- Negative:
  - Missing group_descriptor when module group is not created.
  - Duplicate derived keys in entitlements.
  - Role assignment without identity_id when module group is not created.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-identity-refactor.md`
- Module README + examples + new `docs/IMPORT.md`

## Acceptance Criteria

- No index-based `for_each` for list resources; stable keys everywhere.
- Validations cover defaulting to module-managed group where applicable.
- Outputs are keyed by stable, human-readable keys; role assignment outputs added.
- README and examples updated; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Update `variables.tf`: replace `groups` map with flat group inputs; add `key` fields, group reference validations, default mode.
- [ ] Update `main.tf`: add locals for key normalization, use stable `for_each` keys.
- [ ] Update `outputs.tf`: single group outputs + stable key maps, add `securityrole_assignment_ids`.
- [ ] Add `docs/IMPORT.md` and update module README/examples.
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] Run docs generation and update README.
