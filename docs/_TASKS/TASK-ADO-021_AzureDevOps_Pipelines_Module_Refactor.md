# TASK-ADO-021: Azure DevOps Pipelines Module Refactor
# FileName: TASK-ADO-021_AzureDevOps_Pipelines_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-007
**Status:** 🟠 **Re-opened**

---

## Overview

Refactor `modules/azuredevops_pipelines` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys for list resources, stricter cross-field validation, fixed-name examples,
and missing import docs. Document any deviations required by provider constraints.
The main `azuredevops_build_definition` must be a single (non-iterated) resource with flat inputs; for multiple pipelines use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_build_definition`
- `azuredevops_build_definition_permissions`
- `azuredevops_build_folder`
- `azuredevops_build_folder_permissions`
- `azuredevops_pipeline_authorization`
- `azuredevops_resource_authorization` (legacy)

## Current Gaps (Summary)

- `azuredevops_build_definition` is iterated via `build_definitions` map; should be a single resource with flat inputs and module-level `for_each`.
- List resources use index-based `for_each` (folders, permissions, authorizations), causing unstable addresses.
- Outputs for build folders are keyed by index instead of stable keys.
- No explicit `key` inputs or uniqueness validation for list resources.
- `pipeline_authorizations` does not require pipeline_id or default to the module pipeline.
- `resource_authorizations` allows missing `definition_id` and `type`, despite provider requirements.
- Examples use random names (violates fixed-name examples rule).
- Missing `docs/IMPORT.md` for the module.
- Tests/Makefile/scripts are not aligned with TESTING_GUIDE conventions.

## Target Module Design

### Inputs (Build Definition)

Flat variables for the main build definition (single resource).
Preserve nested objects for repository and triggers.

### Inputs (Build Folders)

`build_folders` (list(object)):
- key (optional string) for stable `for_each`
- path (string)
- description (optional string)

Validation rules:
- path must be non-empty
- for_each key = `coalesce(key, path)` with uniqueness validation

### Inputs (Build Definition Permissions)

`build_definition_permissions` (list(object)):
- key (optional string)
- build_definition_id (optional string)
- principal (string)
- permissions (map(string))
- replace (optional bool, default true)

Validation rules:
- build_definition_id must be non-empty when provided
- when build_definition_id is omitted, the module build definition must be present
- principal non-empty
- permissions values in ["Allow", "Deny", "NotSet"]
- for_each key = `coalesce(key, principal)`

### Inputs (Build Folder Permissions)

`build_folder_permissions` (list(object)):
- key (optional string)
- path (string)
- principal (string)
- permissions (map(string))
- replace (optional bool, default true)

Validation rules:
- path and principal non-empty
- permissions values in ["Allow", "Deny", "NotSet"]
- for_each key = `coalesce(key, "${path}:${principal}")`

### Inputs (Pipeline Authorizations)

`pipeline_authorizations` (list(object)):
- key (optional string)
- resource_id (string)
- type (string)
- pipeline_id (optional string)
- pipeline_project_id (optional string)

Validation rules:
- pipeline_id must be non-empty when provided
- when pipeline_id is omitted, the module build definition must be present
- type in ["endpoint", "queue", "variablegroup", "environment", "repository"]
- resource_id non-empty
- for_each key = `coalesce(key, "${type}:${resource_id}")`

### Inputs (Resource Authorizations - Legacy)

`resource_authorizations` (list(object)):
- key (optional string)
- resource_id (string)
- authorized (bool)
- type (string)
- definition_id (optional string)

Validation rules:
- definition_id must be non-empty when provided
- when definition_id is omitted, the module build definition must be present
- type in ["endpoint", "queue", "variablegroup"]
- resource_id non-empty
- for_each key = `coalesce(key, "${type}:${resource_id}")`

### Locals / Implementation

- Build normalized maps in `locals` for each list input and use them in `for_each`.
- Add `lifecycle` preconditions for defaulted pipeline/definition IDs when module outputs are required.
- Normalize `type` values with `lower()` in resources (or enforce lowercase in validation).

### Outputs

- `build_definition_id` (string)
- `build_folder_ids` (map, keyed by folder key/path)

## Examples

Update examples to use fixed names and stable keys:
- basic: one YAML pipeline with fixed name
- complete: folders + authorizations (show module-level `for_each` for multiple pipelines)
- secure: permissions + explicit authorizations

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - pipeline_id defaulting/required validation
  - resource_authorizations definition_id requirement
  - stable key uniqueness for list inputs
  - allowed values for authorization type
- Integration:
  - create pipeline + folder + authorization
- Negative:
  - duplicate keys
  - missing required identifiers

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-pipelines-refactor.md`

## Acceptance Criteria

- Module aligns with MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (stable keys, validated cross-references).
- `pipeline_authorizations` and `resource_authorizations` enforce required fields and module defaults.
- Outputs keyed by stable, human-readable keys.
- Examples updated with fixed names; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Refactor variables.tf: replace `build_definitions` map with flat build definition inputs; add `key` fields + validations for list inputs.
- [ ] Refactor main.tf: single build definition, normalized maps + stable for_each keys + preconditions.
- [ ] Update outputs.tf: `build_definition_id` and stable build folder map.
- [ ] Add `docs/IMPORT.md`.
- [ ] Update examples (fixed names, new key usage).
- [ ] Update tests (fixtures, unit, terratest, test_config, Makefile/scripts).
- [ ] make docs + update README.
