# TASK-ADO-026: Azure DevOps Work Items Module Refactor
# FileName: TASK-ADO-026_AzureDevOps_Work_Items_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-014
**Status:** ✅ **Done** (2025-12-28)

---

## Overview

Refactor `modules/azuredevops_work_items` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Introduce stable keys for all list-based resources, stronger validation, and optional key-based references
between work items, query folders, and queries.
The main `azuredevops_workitem` must be a single (non-iterated) resource with flat inputs; for multiple work items use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_workitem`
- `azuredevops_workitemquery`
- `azuredevops_workitemquery_folder`
- `azuredevops_workitemquery_permissions`
- `azuredevops_workitemtrackingprocess_process`
- `azuredevops_area_permissions`
- `azuredevops_iteration_permissions`
- `azuredevops_tagging_permissions`

## Current Gaps (Summary)

- `work_items` are modeled as a list and iterated; should be a single resource with flat inputs and module-level `for_each`.
- Index-based `for_each` for work items, queries, folders, and permissions causes unstable resource addresses.
- No `key` inputs for list items; outputs are keyed by index instead of stable identifiers.
- No support for referencing module-created query folders/queries by key.
- `project_id` is required even for org-scoped processes; no validation to enforce project_id when needed.
- `path` fields for permissions are optional with no non-empty validation.
- ID fields (`parent_id`, etc.) are typed as strings and lack basic validation (non-empty/positive).
- Outputs omit query folder IDs and all permissions IDs.
- Missing `docs/IMPORT.md` and README Terraform docs are not generated.

## Target Module Design

### Inputs (Project Context)

- project_id (optional string) — default project for project-scoped resources.

Validation rules:
- If any project-scoped entry omits `project_id`, module `project_id` must be set.

### Inputs (Processes)

- processes (list(object)):
  - key (optional string) for stable for_each
  - name (string, required)
  - parent_process_type_id (string, required)
  - description (optional string)
  - is_default (optional bool)
  - is_enabled (optional bool)
  - reference_name (optional string)

Validation rules:
- name/reference_name must be non-empty when provided.
- for_each key = `coalesce(key, name)` with uniqueness validation.

### Inputs (Work Item)

Single work item per module instance (no list).
- project_id (optional string)
- title (string, required)
- type (string, required)
- state (optional string)
- tags (optional list(string))
- area_path (optional string)
- iteration_path (optional string)
- parent_id (optional number)
- custom_fields (optional map(string))
- verify provider schema for additional optional fields and add if applicable

Validation rules:
- title/type must be non-empty strings.
- parent_id must be a positive number when provided.

### Inputs (Query Folders)

- query_folders (list(object)):
  - key (optional string) for stable for_each
  - project_id (optional string)
  - name (string, required)
  - area (optional string)
  - parent_id (optional number)
  - parent_key (optional string)

Validation rules:
- name must be non-empty.
- Exactly one of `area`, `parent_id`, or `parent_key`.
- `parent_key` must reference an existing folder key.
- for_each key = `coalesce(key, name)` with uniqueness validation.

### Inputs (Queries)

- queries (list(object)):
  - key (optional string) for stable for_each
  - project_id (optional string)
  - name (string, required)
  - wiql (string, required)
  - area (optional string)
  - parent_id (optional number)
  - parent_key (optional string)

Validation rules:
- name/wiql must be non-empty.
- Exactly one of `area`, `parent_id`, or `parent_key`.
- `parent_key` must reference an existing folder key.
- for_each key = `coalesce(key, name)` with uniqueness validation.

### Inputs (Query Permissions)

- query_permissions (list(object)):
  - key (optional string) for stable for_each
  - project_id (optional string)
  - path (optional string)
  - query_key (optional string)
  - folder_key (optional string)
  - principal (string, required)
  - permissions (map(string), required)
  - replace (optional bool)

Validation rules:
- Exactly one of `path`, `query_key`, or `folder_key`.
- `query_key`/`folder_key` must reference existing keys.
- path must be non-empty when provided.
- for_each key = `coalesce(key, principal, path, query_key, folder_key)` with uniqueness validation.

Behavior:
- When `query_key` or `folder_key` is set, derive `path` from module-created resources.

### Inputs (Area / Iteration / Tagging Permissions)

- area_permissions / iteration_permissions / tagging_permissions (list(object)):
  - key (optional string) for stable for_each
  - project_id (optional string)
  - path (string, required)
  - principal (string, required)
  - permissions (map(string), required)
  - replace (optional bool)

Validation rules:
- path must be non-empty.
- for_each key = `coalesce(key, principal, path)` with uniqueness validation.

### Outputs

- process_ids (map, keyed by process key)
- work_item_id (string)
- query_folder_ids (map, keyed by folder key)
- query_ids (map, keyed by query key)
- query_permission_ids / area_permission_ids / iteration_permission_ids / tagging_permission_ids (maps keyed by entry key)

## Examples

Update examples to show stable keys and key-based references:
- basic: single work item.
- complete: process + query folder + query + permissions referencing `query_key`/`folder_key`.
- secure: area/iteration/tagging permissions with explicit paths and keys.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - key uniqueness validation for all list inputs.
  - project_id required when project-scoped entries omit it.
  - parent_id validation for work item.
  - query permissions selector validation (path vs query_key vs folder_key).
- Integration:
  - create folder + query + permissions using key-based references.
  - create work item with parent_id.
- Negative:
  - duplicate keys.
  - invalid parent_id/query_key references.
  - missing project_id when required.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-work-items-refactor.md`
- `modules/azuredevops_work_items/docs/IMPORT.md`

## Acceptance Criteria

- Module aligns with MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (stable keys, validations, cross-field rules).
- Project-scoped resources validate `project_id` availability.
- Key-based references for query folders/queries are supported.
- Outputs keyed by stable, human-readable keys.
- README + examples + docs/IMPORT.md updated.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [x] Update variables.tf: move `processes` to list(object), replace `work_items` list with a single work item input, add validations and project_id gating.
- [x] Refactor main.tf for stable for_each on list resources and defaulted IDs.
- [x] Update outputs.tf with `work_item_id` and stable maps for other resources.
- [x] Add `docs/IMPORT.md` and regenerate README (terraform-docs).
- [x] Update examples (basic/complete/secure) to use the new single work item interface.
- [x] Update tests (fixtures, unit, terratest, test_config).
- [x] make docs + update examples list.
