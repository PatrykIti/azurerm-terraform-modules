# TASK-ADO-020: Azure DevOps Extension Module Refactor
# FileName: TASK-ADO-020_AzureDevOps_Extension_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Small
**Dependencies:** TASK-ADO-005
**Status:** ✅ **Done** (2025-12-28)

---

## Overview

Refactor `modules/azuredevops_extension` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
The `azuredevops_extension` resource must be a single (non-iterated) block with flat inputs.
For multiple extensions, use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_extension`

## Current Gaps (Summary)

- `azuredevops_extension` is iterated via `extensions` list instead of a single resource.
- Core inputs are nested in a list(object); should be flat variables.
- Output `extension_ids` is a map; should be a single output for the module instance.
- Examples/fixtures/tests assume list-based API; need module-level `for_each` patterns.
- Missing `docs/IMPORT.md` for the module.

## Target Module Design

### Inputs (Extension)

Flat variables for the extension:
- publisher_id (string, required)
- extension_id (string, required)
- version (optional string, default null)

Validation rules:
- publisher_id and extension_id must be non-empty after trimspace
- version must be non-empty when provided

### Outputs

- extension_id (string, resource ID)

## Examples

Update examples to show single extension usage and module-level `for_each`:
- basic: one extension (flat inputs)
- complete: module-level `for_each` over list/map with optional version pinning
- secure: allowlist-based module-level `for_each`

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - required publisher_id/extension_id validation
  - version non-empty validation
  - output `extension_id` exists
- Integration:
  - create single extension (basic)
  - module-level `for_each` for multiple extensions (complete)
- Negative:
  - empty publisher_id or extension_id
  - version provided as empty string

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-extension-refactor.md`

## Acceptance Criteria

- Module follows MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (flat core inputs, single resource).
- Examples/fixtures/tests updated to module-level `for_each` for multiple extensions.
- `docs/IMPORT.md` added and linked.
- README + examples + tests updated and passing.
- Breaking change documented (major bump).

## Implementation Checklist

- [ ] Refactor variables.tf: replace `extensions` list with flat inputs + validations.
- [ ] Refactor main.tf: single `azuredevops_extension` resource block.
- [ ] Update outputs.tf: replace `extension_ids` map with `extension_id`.
- [ ] Update examples/fixtures/tests to new interface (module-level `for_each`).
- [ ] Add docs/IMPORT.md.
- [ ] Update README + regenerate docs + update examples list.
- [ ] Update tests (fixtures, unit, terratest, test_config).
