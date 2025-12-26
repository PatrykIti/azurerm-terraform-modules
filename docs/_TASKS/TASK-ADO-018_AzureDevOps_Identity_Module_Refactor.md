# TASK-ADO-018: Azure DevOps Identity Module Refactor
# FileName: TASK-ADO-018_AzureDevOps_Identity_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-002
**Status:** ✅ **Done** (2025-12-26)

---

## Overview

Refactor `modules/azuredevops_identity` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys, stronger cross-field validation, and missing import docs.
Document any deviations required by resource-specific constraints.

## Scope (Provider Resources)

- `azuredevops_group`
- `azuredevops_group_membership`
- `azuredevops_group_entitlement`
- `azuredevops_user_entitlement`
- `azuredevops_service_principal_entitlement`
- `azuredevops_securityrole_assignment`

## Current Gaps (Summary)

- List resources use index-based `for_each` (memberships, entitlements, role assignments), causing unstable addressing.
- Outputs for entitlements and memberships are keyed by index instead of stable keys.
- No validation that `group_key`, `member_group_keys`, or `identity_group_key` exist in `groups`.
- No explicit `key` inputs or uniqueness validation for list resources.
- `group_memberships.mode` defaults to `null` instead of explicit `add`.
- Missing `docs/IMPORT.md` for the module.
- No output for `azuredevops_securityrole_assignment` IDs.

## Target Module Design

### Inputs (Groups)

Keep current `groups` map(object) schema and validation.

### Inputs (Group Memberships)

`group_memberships` (list(object)):
- key (optional string) for stable `for_each`
- group_descriptor (optional string)
- group_key (optional string)
- member_descriptors (optional list(string), default [])
- member_group_keys (optional list(string), default [])
- mode (optional string, default "add")

Validation rules:
- Exactly one of `group_descriptor` or `group_key`.
- At least one member via `member_descriptors` or `member_group_keys`.
- `group_key` and `member_group_keys` must exist in `groups`.
- Unique for_each keys using `coalesce(key, group_descriptor, group_key)`.

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
- identity_id (optional string)
- identity_group_key (optional string)

Validation rules:
- Exactly one of `identity_id` or `identity_group_key`.
- `identity_group_key` must exist in `groups`.
- Unique keys using `coalesce(key, "${scope}/${resource_id}/${role_name}/${identity_id or identity_group_key}")`.

### Locals / Implementation

- Build normalized maps in `locals` for each list input (memberships, entitlements, assignments).
- Use the normalized maps for `for_each` to ensure stable resource addressing.
- Default `mode` to `add` if unset.
- Consider `distinct()` for membership `members` if duplicates appear in inputs.

### Outputs

- `group_ids` and `group_descriptors` (unchanged).
- `group_membership_ids` keyed by membership key.
- `group_entitlement_ids` and `group_entitlement_descriptors` keyed by entitlement key.
- `user_entitlement_ids` and `user_entitlement_descriptors` keyed by entitlement key.
- `service_principal_entitlement_ids` and `service_principal_entitlement_descriptors` keyed by entitlement key.
- `securityrole_assignment_ids` keyed by assignment key (new).

## Examples

Update examples for stable keys and new validations:
- basic: one group.
- complete: groups + membership + all entitlements + role assignment (show optional `key`).
- secure: explicit membership `mode = "overwrite"` and minimal entitlements.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - Unique key validation for each list resource.
  - `group_key`/`member_group_keys`/`identity_group_key` reference validation.
  - Membership mode default (add) and allowed values.
  - Entitlement selector validation (name vs origin + origin_id).
- Integration:
  - Create groups + membership + one entitlement type; validate stable output keys.
- Negative:
  - Unknown group key in membership.
  - Duplicate derived keys in entitlements.
  - Role assignment with both identity_id and identity_group_key.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-identity-refactor.md`
- Module README + examples + new `docs/IMPORT.md`

## Acceptance Criteria

- No index-based `for_each` for list resources; stable keys everywhere.
- Validations cover cross-object references to module-managed groups.
- Outputs are keyed by stable, human-readable keys; role assignment outputs added.
- README and examples updated; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [x] Update `variables.tf`: add `key` fields, add group reference validations, add default mode.
- [x] Update `main.tf`: add locals for key normalization, use stable `for_each` keys.
- [x] Update `outputs.tf`: stable key maps, add `securityrole_assignment_ids`.
- [x] Add `docs/IMPORT.md` and update module README/examples.
- [x] Update tests (fixtures, unit, terratest, test_config).
- [x] Run docs generation and update README.
