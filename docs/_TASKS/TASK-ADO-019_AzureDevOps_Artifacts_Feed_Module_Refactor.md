# TASK-ADO-019: Azure DevOps Artifacts Feed Module Refactor
# FileName: TASK-ADO-019_AzureDevOps_Artifacts_Feed_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-011
**Status:** 🟠 **Re-opened**

---

## Overview

Refactor `modules/azuredevops_artifacts_feed` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable addressing for child resources, missing provider inputs, and tighter validation.
The main `azuredevops_feed` must be a single (non-iterated) resource with flat inputs; for multiple feeds use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_feed`
- `azuredevops_feed_permission`
- `azuredevops_feed_retention_policy`

## Current Gaps (Summary)

- `feeds` input is iterated; should be a single feed resource with flat inputs and module-level `for_each`.
- Feed input lacks `description` (provider field) and does not validate `project_id`/`name` when provided.
- `feed_permissions` and `feed_retention_policies` use index-based `for_each`, causing unstable plans on reordering.
- `feed_id` is not validated as non-empty when set.
- `project_id` for permissions/retention is not derived from the module feed when `feed_id` is omitted.
- Missing `docs/IMPORT.md` for the module.
- README Terraform docs are not generated.

## Target Module Design

### Inputs (Feed)

Flat variables for the main feed (single resource):
- name (string, required)
- project_id (string, required)
- description (optional string)
- features (optional object with permanent_delete, restore)
- verify provider schema for any additional optional fields and add if applicable

Validation rules:
- name and project_id must be non-empty strings when provided.
- description must be non-empty when provided.

### Inputs (Feed Permissions)

- feed_permissions (list(object)):
  - key (optional string) for stable for_each
  - feed_id (optional string)
  - identity_descriptor (string)
  - role (string: reader, contributor, collaborator, administrator)
  - project_id (optional string)
  - display_name (optional string)

Validation rules:
- feed_id must be non-empty when provided.
- When feed_id is omitted, the module feed must be present.
- Unique key across entries (coalesce key, identity_descriptor).

Behavior:
- If feed_id is omitted and project_id is omitted, derive project_id from the module feed.
- Normalize role to lowercase before sending to provider.

### Inputs (Feed Retention Policies)

- feed_retention_policies (list(object)):
  - key (optional string) for stable for_each
  - feed_id (optional string)
  - count_limit (number > 0)
  - days_to_keep_recently_downloaded_packages (number > 0)
  - project_id (optional string)

Validation rules:
- feed_id must be non-empty when provided.
- When feed_id is omitted, the module feed must be present.
- Unique key across entries (coalesce key, count_limit, days_to_keep_recently_downloaded_packages).

Behavior:
- If feed_id is omitted and project_id is omitted, derive project_id from the module feed.

### Outputs

- feed_id (string)
- feed_name (string)
- feed_project_id (string)
- optional: permission_ids/retention_policy_ids if needed downstream

## Examples

Update examples to show stable key usage and derived project_id:
- basic: single feed only.
- complete: feed + permissions + retention with feed_id omitted (module feed defaults, no project_id duplication).
- secure: feed with reader permissions + stricter retention.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - feed description validation.
  - feed_id defaulting validation for permissions/retention.
  - unique key validation for permissions/retention.
  - role normalization and allowed values.
- Integration:
  - feed + permissions + retention with derived project_id.
- Negative:
  - missing feed_id when module feed is not created.
  - duplicate key in permissions/retention list.
  - invalid retention limits.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-artifacts-feed-refactor.md`
- `modules/azuredevops_artifacts_feed/docs/IMPORT.md`

## Acceptance Criteria

- Module aligns with MODULE_GUIDE and TERRAFORM_BEST_PRACTICES.
- Stable for_each keys for permissions/retention.
- Feed inputs include provider fields (at minimum description).
- README + examples + docs/IMPORT.md updated.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Update variables.tf: replace `feeds` map with flat feed inputs, add validations and key fields.
- [ ] Refactor main.tf for stable for_each, role normalization, and project_id derivation (module feed defaults).
- [ ] Update outputs.tf if additional outputs are added.
- [ ] Add docs/IMPORT.md and regenerate README (terraform-docs).
- [ ] Update examples (basic/complete/secure) for the new interface.
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] make docs + update examples list.
