# TASK-ADO-029: Azure DevOps Repository Policies Restructure
# FileName: TASK-ADO-029_AzureDevOps_Repository_Policies_Restructure.md

**Priority:** High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-023
**Status:** Proposed

---

## Overview

Restructure `modules/azuredevops_repository` to manage repository policies in a clearer, nested way:
- Repository-level policies are defined in a single `policies` object.
- Branch-level policies are nested per branch under `branches[*].policies`.
- Branch policies that can have multiple entries (build validation, status checks, auto reviewers) are lists with a required `name`.
- No project-wide policy scope in this module (handled by a separate module).
- The repository resource is always managed by this module (create or import only).

This is a breaking change. Backward compatibility is not required.

---

## Goals

- Make policy inputs simple and explicit (no generic `key` fields; use `name` for multi-policy lists).
- Enforce a strict repository scope for this module (no policies or branches without the repository resource).
- Keep policy scope logic inside the module and derived from branch names (no user-provided scope blocks).
- Preserve the ability to set multiple policies for build validation, status checks, and auto reviewers.
- Update all module examples to the new policy schema (all `examples/*` will be out of date).

## Non-Goals

- Project-wide policy management (handled by a separate module).
- Backward compatibility with existing variable shapes.
- Supporting policies without a repository resource.

---

## Target Input Design

### Repository (always managed)

- `project_id` (string, required)
- `name` (string, required)
- `default_branch` (optional string)
- `parent_repository_id` (optional string)
- `disabled` (optional bool)
- `initialization` (optional object, default null; dynamic block used only when set)

`initialization` object:
- `init_type` (optional string, default "Uninitialized")
- `source_type` (optional string)
- `source_url` (optional string)
- `service_connection_id` (optional string)
- `username` (optional string)
- `password` (optional string)

Validation rules (as-is, but now repository is always present):
- `name` must be non-empty.
- `default_branch` must be non-empty and start with `refs/heads/` when provided.
- `init_type` allowed: Uninitialized, Clean, Import.
- If `init_type = Import`, require `source_url` and exactly one auth method (service_connection_id OR username/password).
- If `init_type != Import`, disallow import-only fields.

### Repository Policies (single object)

`policies` (optional object):
- `author_email_pattern` (optional object)
- `file_path_pattern` (optional object)
- `case_enforcement` (optional object)
- `reserved_names` (optional object)
- `maximum_path_length` (optional object)
- `maximum_file_size` (optional object)

Policy object shapes (examples):
- `author_email_pattern`: `enabled`, `blocking`, `author_email_patterns` (list(string), required)
- `file_path_pattern`: `enabled`, `blocking`, `filepath_patterns` (list(string), required)
- `case_enforcement`: `enabled`, `blocking`, `enforce_consistent_case` (bool, required)
- `reserved_names`: `enabled`, `blocking`
- `maximum_path_length`: `enabled`, `blocking`, `max_path_length` (number > 0)
- `maximum_file_size`: `enabled`, `blocking`, `max_file_size` (number > 0)

Notes:
- `repository_ids` is not exposed; the module always uses the managed repository ID.
- Each repository policy is at most one object.

### Branches

`branches` (list(object)):
- `name` (string, required)
- `ref_branch` (optional string)
- `ref_tag` (optional string)
- `ref_commit_id` (optional string)
- `policies` (optional object)

Validation rules:
- branch names must be unique within the list.
- only one of `ref_branch`, `ref_tag`, `ref_commit_id` can be set per branch.

### Branch Policies (nested per branch)

`branches[*].policies` (optional object):

Single-instance policies (0/1 per branch):
- `min_reviewers` (object)
- `comment_resolution` (object)
- `work_item_linking` (object)
- `merge_types` (object)

Multi-instance policies (list, each requires `name`):
- `build_validation` (list(object))
- `status_check` (list(object))
- `auto_reviewers` (list(object))

Multi-instance policy requirements:
- `build_validation`: `name`, `build_definition_id`, `display_name`, optional tuning fields
- `status_check`: `name`, `genre` optional, `display_name` optional, optional tuning fields
- `auto_reviewers`: `name`, `auto_reviewer_ids`, optional tuning fields

Notes:
- `name` is required for list policies and must be unique within the branch.
- No user-provided `scope` blocks. Scope is derived from branch name.

---

## Locals and for_each Strategy

We will flatten nested policy lists into maps for stable `for_each` keys.

Keying strategy:
- Single policies: `<branch_name>:<policy_type>`
- List policies: `<branch_name>:<policy_name>`

Example (build validation):

```
locals {
  branch_build_validations = {
    for item in flatten([
      for branch in var.branches : [
        for policy in coalesce(try(branch.policies.build_validation, []), []) : {
          branch = branch
          policy = policy
        }
      ]
    ]) : format("%s:%s", item.branch.name, item.policy.name) => item
  }
}
```

Scope generation (always per branch, no user input):
- `match_type = "Exact"`
- `repository_ref = "refs/heads/${branch.name}"`
- `repository_id = azuredevops_git_repository.git_repository.id`

---

## Resource Mapping

Repository:
- `azuredevops_git_repository` (always present)
- `initialization` is dynamic and omitted when `initialization` is null

Branches/Files/Permissions:
- `azuredevops_git_repository_branch` uses `branches` list
- `azuredevops_git_repository_file` uses `files` list
- `azuredevops_git_permissions` uses `git_permissions` list

Repository Policies (single each, conditional):
- `azuredevops_repository_policy_author_email_pattern`
- `azuredevops_repository_policy_file_path_pattern`
- `azuredevops_repository_policy_case_enforcement`
- `azuredevops_repository_policy_reserved_names`
- `azuredevops_repository_policy_max_path_length`
- `azuredevops_repository_policy_max_file_size`

Branch Policies (per branch and per policy):
- `azuredevops_branch_policy_min_reviewers`
- `azuredevops_branch_policy_comment_resolution`
- `azuredevops_branch_policy_work_item_linking`
- `azuredevops_branch_policy_merge_types`
- `azuredevops_branch_policy_build_validation`
- `azuredevops_branch_policy_status_check`
- `azuredevops_branch_policy_auto_reviewers`

---

## Outputs

Update outputs to reflect new keys:
- `repository_id`, `repository_url` use direct resource ID (no `[0]` index)
- `branch_ids` keyed by branch name
- `policy_ids` keyed by `<branch_name>:<policy_type>` for single policies and `<branch_name>:<policy_name>` for list policies
- `repo_*` policy IDs keyed by policy type name

---

## Files to Update

- `modules/azuredevops_repository/variables.tf`
- `modules/azuredevops_repository/main.tf`
- `modules/azuredevops_repository/outputs.tf`
- `modules/azuredevops_repository/docs/IMPORT.md`
- `modules/azuredevops_repository/README.md` (terraform-docs regeneration)
- `modules/azuredevops_repository/examples/basic/*`
- `modules/azuredevops_repository/examples/complete/*`
- `modules/azuredevops_repository/examples/secure/*`
- `modules/azuredevops_repository/tests/fixtures/*`
- `modules/azuredevops_repository/tests/unit/*`

---

## Tests and Validation Updates

Unit tests to update or replace:
- Remove tests that expect no repository resource by default.
- Remove validations tied to `repository_id` inputs (no longer exposed).
- Add validations for:
  - unique branch names
  - only one of ref_branch/ref_tag/ref_commit_id
  - policy list `name` uniqueness per branch
  - required fields (build_definition_id, display_name, auto_reviewer_ids, reviewer_count > 0)
  - repo policy constraints (max_file_size/max_path_length > 0, patterns non-empty)

Fixtures and examples should follow the new input schema and produce deterministic, stable plans.

---

## Implementation Steps

1) Redefine variables
   - Remove `branch_policy_*` and `repository_policy_*` list variables.
   - Add `policies` and `branches[*].policies` structures as described.
   - Remove `repository_id` from branch/file/permission inputs.
   - Require `name` at repository level.

2) Rebuild locals and resources
   - Remove old policy locals.
   - Add new flattening locals for list policies.
   - Generate scope internally per branch (Exact + refs/heads/<branch.name>).
   - Keep repository policies tied to the module repository ID.

3) Update outputs
   - Adjust `policy_ids` keys to match new keys.
   - Update `repository_id`/`repository_url` to direct resource access.

4) Update docs and examples
   - Rewrite `docs/IMPORT.md` for new addresses and inputs.
   - Update example inputs and README generation markers.

5) Update tests/fixtures
   - Align test variables with the new schema.
   - Add new validation coverage for policy naming and required fields.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-azuredevops_repository.md`

---

## Migration Notes

This is a breaking change. Existing configurations must be rewritten to the new policy structure. The module will no longer allow policy management without a repository resource in state.
