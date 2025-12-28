# TASK-ADO-023: Azure DevOps Repository Module Refactor
# FileName: TASK-ADO-023_AzureDevOps_Repository_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Large
**Dependencies:** TASK-ADO-006
**Status:** 🟠 **Re-opened**

---

## Overview

Refactor `modules/azuredevops_repository` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
The main `azuredevops_git_repository` must be a single (non-iterated) resource with flat inputs; for multiple repositories use module-level `for_each`.
Move all list resources to stable for_each keys, add missing validations, tighten repository initialization rules, and update examples/docs/tests.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_git_repository`
- `azuredevops_git_repository_branch`
- `azuredevops_git_repository_file`
- `azuredevops_git_permissions`
- `azuredevops_branch_policy_auto_reviewers`
- `azuredevops_branch_policy_build_validation`
- `azuredevops_branch_policy_comment_resolution`
- `azuredevops_branch_policy_merge_types`
- `azuredevops_branch_policy_min_reviewers`
- `azuredevops_branch_policy_status_check`
- `azuredevops_branch_policy_work_item_linking`
- `azuredevops_repository_policy_author_email_pattern`
- `azuredevops_repository_policy_case_enforcement`
- `azuredevops_repository_policy_check_credentials`
- `azuredevops_repository_policy_file_path_pattern`
- `azuredevops_repository_policy_max_file_size`
- `azuredevops_repository_policy_max_path_length`
- `azuredevops_repository_policy_reserved_names`

## Current Gaps (Summary)

- `repositories` are modeled as a map and iterated; should be a single repository resource with flat inputs and module-level `for_each`.
- Branches/files/permissions/policies use index-based `for_each`, causing unstable addressing; outputs are index-keyed.
- No `key` fields or uniqueness validation for list inputs; reordering causes drift.
- `repositories.initialization` is required and lacks defaults; import rules (source_url/auth) are not fully validated.
- Repository references are not validated when defaulting to the module repository.
- `git_permissions` allows missing repository reference; permissions values are not validated.
- Branch policy scopes allow missing repository_id and unvalidated match_type values.
- Repository policy inputs allow empty repository targets and lack validation for required lists/numeric limits.
- Examples use random names (violates fixed-name examples rule).
- Missing `docs/IMPORT.md` for the module.
- Tests cover only basic validation; missing stable-key, cross-field, and policy-specific checks.

## Target Module Design

### Inputs (Repository)

Flat variables for the main repository (single resource).
Add optional `initialization` object with sensible defaults.

Fields:
- name (optional string)
- default_branch (optional string)
- parent_repository_id (optional string)
- disabled (optional bool)
- initialization (optional object):
  - init_type (optional string, default "Uninitialized")
  - source_type (optional string, default "Git" when init_type = "Import")
  - source_url (optional string)
  - service_connection_id (optional string)
  - username (optional string)
  - password (optional string)

Validation rules:
- name/default_branch non-empty when provided; default_branch must start with `refs/heads/`.
- init_type allowed values: Uninitialized, Clean, Import.
- If init_type = Import, require source_url and exactly one of service_connection_id or username/password.
- If init_type != Import, disallow source_* and auth fields.

### Inputs (Branches)

branches (list(object)):
- key (optional string)
- repository_id (optional string)
- name (string, required)
- ref_branch/ref_tag/ref_commit_id (optional)

Validation rules:
- repository_id must be non-empty when provided.
- when repository_id is omitted, the module repository must be present.
- name non-empty.
- only one of ref_branch/ref_tag/ref_commit_id (or default to main branch when omitted).
- for_each key = `coalesce(key, name)` with uniqueness validation.

### Inputs (Files)

files (list(object)):
- key (optional string)
- repository_id (optional string)
- file (string, required)
- content (string, required)
- branch (optional string)
- commit_message (optional string)
- overwrite_on_create (optional bool)
- author_name/author_email/committer_name/committer_email (optional string)

Validation rules:
- repository selection same as branches (default to module repo).
- file/content non-empty.
- commit_message non-empty when provided (and required if provider demands it).
- for_each key = `coalesce(key, file)` with uniqueness validation.

### Inputs (Git Permissions)

git_permissions (list(object)):
- key (optional string)
- repository_id (optional string)
- branch_name (optional string)
- principal (string, required)
- permissions (map(string), required)
- replace (optional bool, default true)

Validation rules:
- repository_id must be non-empty when provided.
- when repository_id is omitted, the module repository must be present.
- principal non-empty.
- permissions values in ["Allow", "Deny", "NotSet"].
- for_each key = `coalesce(key, "${branch_name or "root"}:${principal}")`.

### Inputs (Branch Policies)

For each branch_policy_* list:
- key (optional string)
- enabled/blocking (optional bool)
- policy-specific fields
- scope (list(object)):
  - repository_id (optional string)
  - repository_ref (optional string)
  - match_type (optional string)

Validation rules:
- scope list not empty.
- repository_id must be non-empty when provided; default to module repository when omitted.
- match_type allowed values (DefaultBranch, Exact, Prefix); repository_ref required when match_type != DefaultBranch.
- for_each key = `coalesce(key, policy_type)` with uniqueness validation (require `key` for multiple entries per policy type).
- policy-specific: reviewer_count > 0, auto_reviewer_ids non-empty, build_definition_id/display_name non-empty,
  valid_duration >= 0, etc.

### Inputs (Repository Policies)

For each repository_policy_* list:
- key (optional string)
- enabled/blocking (optional bool)
- repository_ids (optional list(string))
- policy-specific fields

Validation rules:
- repository_ids must not be empty unless explicitly supporting apply-to-all behavior.
- de-duplicate IDs and validate non-empty strings.
- author_email_patterns/filepath_patterns non-empty when set.
- max_file_size/max_path_length > 0.
- for_each key = `coalesce(key, policy_type)` with uniqueness validation (require `key` for multiple entries per policy type).

### Locals / Implementation

- Build normalized maps for branches/files/permissions/policies to drive stable for_each.
- Add lifecycle preconditions for defaulted repository IDs when module outputs are required.
- Centralize repository ID resolution for policy lists to avoid duplicated concat/try logic.

### Outputs

- repository_id (string)
- repository_url (string)
- branch_ids (map, keyed by branch key)
- policy_ids (map of maps, keyed by policy key)
- optional: file_ids/permission_ids if needed downstream

## Examples

Update examples to use fixed names and stable keys:
- basic: single repo + README file (no random provider)
- complete: repo + branch + file + permissions + representative policies (show module-level `for_each` for multiple repos)
- secure: repo with stricter review/status/repository policies

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - initialization validation (Import requirements)
  - repository_id defaulting/required validation
  - stable key uniqueness for list inputs
  - permissions allowed values
  - policy-specific constraints (reviewer_count, max_file_size, etc.)
- Integration:
  - create repo + branch + file + policy with stable keys
- Negative:
  - missing repository_id when module repository is not created
  - duplicate keys
  - invalid init_type/import fields

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-repository-refactor.md`

## Acceptance Criteria

- Module aligns with MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (stable keys, validated cross-references).
- Repository initialization supports simple defaults and enforces Import requirements.
- Branch/policy resources use stable, human-readable keys and outputs.
- Examples updated with fixed names; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Refactor variables.tf: replace `repositories` map with flat repository inputs, add initialization defaults and validations.
- [ ] Refactor main.tf: single repository, normalized maps, stable for_each keys, preconditions, shared repository ID resolver.
- [ ] Update outputs.tf: repository_id/url outputs + stable branch/policy maps (and any new outputs).
- [ ] Add `docs/IMPORT.md`.
- [ ] Update examples (fixed names, new key usage).
- [ ] Update tests (fixtures, unit, terratest, test_config, Makefile/scripts).
- [ ] make docs + update README.
