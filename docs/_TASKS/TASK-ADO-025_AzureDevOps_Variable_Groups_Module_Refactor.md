# TASK-ADO-025: Azure DevOps Variable Groups Module Refactor
# FileName: TASK-ADO-025_AzureDevOps_Variable_Groups_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-010
**Status:** ✅ **Done** (2025-12-28)

---

## Overview

Refactor `modules/azuredevops_variable_groups` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
The main `azuredevops_variable_group` must be a single (non-iterated) resource with flat inputs.
Permissions should use list(object) with stable for_each keys; for multiple groups use module-level for_each.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_variable_group`
- `azuredevops_variable_group_permissions`
- `azuredevops_library_permissions`

## Current Gaps (Summary)

- `azuredevops_variable_group` is iterated via `var.variable_groups` map; core inputs are nested.
- `key_vaults` is modeled as a list and does not match provider block semantics (`key_vault`); max-one is not enforced.
- `variable_group_permissions` and `library_permissions` use index-based for_each, producing unstable addresses.
- `variable_group_permissions` does not validate/default the target group when `variable_group_id` is omitted.
- Outputs are maps keyed by group key; module should expose single outputs for a single group.
- Examples use random suffix provider and dynamic names (violates fixed-name examples rule).
- Missing `docs/IMPORT.md`.

## Target Module Design

### Inputs (Core Variable Group)

Flat variables for the main group:
- name (string, required)
- project_id (string, required)
- description (optional string)
- allow_access (bool, default false)

### Inputs (Variables)

- variables (list(object)):
  - name (string, required)
  - value (optional string)
  - secret_value (optional string)
  - is_secret (optional bool)

Validation rules:
- name must be non-empty
- exactly one of value or secret_value must be set
- if secret_value is set, is_secret must be true (or auto-defaulted to true)
- if is_secret is true, secret_value is required

### Inputs (Key Vault)

Single optional object `key_vault`:
- name (string, required)
- service_endpoint_id (string, required)
- search_depth (optional number)

Validation rules:
- name and service_endpoint_id must be non-empty
- search_depth >= 0 when provided

### Inputs (Variable Group Permissions)

- variable_group_permissions (list(object)):
  - key (optional string) for stable for_each
  - variable_group_id (optional string) — default to module variable group ID when omitted
  - principal (string, required)
  - permissions (map(string), required)
  - replace (optional bool, default true)

Validation rules:
- principal must be non-empty
- for_each key = `coalesce(key, principal)` with uniqueness validation
- when variable_group_id is omitted, module variable group must be present

### Inputs (Library Permissions)

- library_permissions (list(object)):
  - key (optional string) for stable for_each
  - principal (string, required)
  - permissions (map(string), required)
  - replace (optional bool, default true)

Validation rules:
- principal must be non-empty
- for_each key = `coalesce(key, principal)` with uniqueness validation

### Outputs

- variable_group_id (string)
- variable_group_name (string)

## Examples

Update examples to show single group usage with fixed names:
- basic: one variable group with plain variables
- complete: variable group + key_vault + variable group permissions + library permissions
- secure: allow_access false + secret variables

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - variable name required
  - value vs secret_value exclusivity
  - secret_value requires is_secret
  - key_vault required fields and search_depth validation
  - stable key uniqueness for permissions
- Integration:
  - create variable group + permissions
- Negative:
  - variable with both value and secret_value
  - secret_value without is_secret
  - duplicate permission keys

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-variable-groups-refactor.md`

## Acceptance Criteria

- Module follows MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (single variable group, flat inputs, stable keys).
- Permissions can target the module group by default or external IDs when provided.
- Outputs are single values (id/name) and safe for missing optional blocks.
- Examples updated with fixed names; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Refactor variables.tf: replace `variable_groups` map with flat inputs; add validations and optional key fields.
- [ ] Refactor main.tf: single `azuredevops_variable_group`; optional `key_vault`; stable for_each for permissions.
- [ ] Update outputs.tf: `variable_group_id` and `variable_group_name` outputs.
- [ ] Add `docs/IMPORT.md`.
- [ ] Update examples (fixed names, single group usage).
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] make docs + update README.
