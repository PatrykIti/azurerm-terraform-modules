# TASK-ADO-021: Azure DevOps Pipelines Module Refactor
# FileName: TASK-ADO-021_AzureDevOps_Pipelines_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-007
**Status:** ✅ **Done** (2025-12-25)

---

## Overview

Refactor `modules/azuredevops_pipelines` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys for list resources, stricter cross-field validation, fixed-name examples,
and missing import docs. Document any deviations required by provider constraints.

## Scope (Provider Resources)

- `azuredevops_build_definition`
- `azuredevops_build_definition_permissions`
- `azuredevops_build_folder`
- `azuredevops_build_folder_permissions`
- `azuredevops_pipeline_authorization`
- `azuredevops_resource_authorization` (legacy)

## Current Gaps (Summary)

- List resources use index-based `for_each` (folders, permissions, authorizations), causing unstable addresses.
- Outputs for build folders are keyed by index instead of stable keys.
- No explicit `key` inputs or uniqueness validation for list resources.
- `pipeline_authorizations` does not require exactly one of `pipeline_id` or `pipeline_key`.
- `resource_authorizations` allows missing `definition_id`/`build_definition_key` and `type`, despite provider requirements.
- `*_key` lookups can resolve to null without validation when referencing `build_definitions`.
- Examples use random names (violates fixed-name examples rule).
- Missing `docs/IMPORT.md` for the module.
- Tests/Makefile/scripts are not aligned with TESTING_GUIDE conventions.

## Target Module Design

### Inputs (Build Definitions)

Keep `build_definitions` as map(object) with default name = key.
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
- build_definition_key (optional string)
- principal (string)
- permissions (map(string))
- replace (optional bool, default true)

Validation rules:
- exactly one of `build_definition_id` or `build_definition_key`
- principal non-empty
- permissions values in ["Allow", "Deny", "NotSet"]
- `build_definition_key` must exist in `build_definitions`
- for_each key = `coalesce(key, "${build_definition_key or build_definition_id}:${principal}")`

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
- pipeline_key (optional string)
- pipeline_project_id (optional string)

Validation rules:
- exactly one of `pipeline_id` or `pipeline_key`
- type in ["endpoint", "queue", "variablegroup", "environment", "repository"]
- resource_id non-empty
- `pipeline_key` must exist in `build_definitions`
- for_each key = `coalesce(key, "${pipeline_id or pipeline_key}:${type}:${resource_id}")`

### Inputs (Resource Authorizations - Legacy)

`resource_authorizations` (list(object)):
- key (optional string)
- resource_id (string)
- authorized (bool)
- type (string)
- definition_id (optional string)
- build_definition_key (optional string)

Validation rules:
- exactly one of `definition_id` or `build_definition_key`
- type in ["endpoint", "queue", "variablegroup"]
- resource_id non-empty
- `build_definition_key` must exist in `build_definitions`
- for_each key = `coalesce(key, "${definition_id or build_definition_key}:${type}:${resource_id}")`

### Locals / Implementation

- Build normalized maps in `locals` for each list input and use them in `for_each`.
- Add `lifecycle` preconditions for any `*_key` references to ensure keys exist.
- Normalize `type` values with `lower()` in resources (or enforce lowercase in validation).

### Outputs

- `build_definition_ids` (map, keyed by build definition key)
- `build_folder_ids` (map, keyed by folder key/path)

## Examples

Update examples to use fixed names and stable keys:
- basic: one YAML pipeline with fixed name
- complete: folders + multiple pipelines + authorizations
- secure: permissions + explicit authorizations

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - pipeline_id vs pipeline_key validation
  - resource_authorizations definition_id/build_definition_key requirement
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
- `pipeline_authorizations` and `resource_authorizations` enforce required fields and key references.
- Outputs keyed by stable, human-readable keys.
- Examples updated with fixed names; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [x] Refactor variables.tf: add `key` fields + validations for list inputs.
- [x] Refactor main.tf: normalized maps + stable for_each keys + preconditions.
- [x] Update outputs.tf: stable build folder map.
- [x] Add `docs/IMPORT.md`.
- [x] Update examples (fixed names, new key usage).
- [x] Update tests (fixtures, unit, terratest, test_config, Makefile/scripts).
- [x] make docs + update README.
