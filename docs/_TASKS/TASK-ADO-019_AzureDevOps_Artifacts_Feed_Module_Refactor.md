# TASK-ADO-019: Azure DevOps Artifacts Feed Module Refactor
# FileName: TASK-ADO-019_AzureDevOps_Artifacts_Feed_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-011
**Status:** ✅ **Done** (2025-12-25)

---

## Overview

Refactor `modules/azuredevops_artifacts_feed` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable addressing for child resources, missing provider inputs, and tighter validation.

## Scope (Provider Resources)

- `azuredevops_feed`
- `azuredevops_feed_permission`
- `azuredevops_feed_retention_policy`

## Current Gaps (Summary)

- `feeds` input lacks `description` (provider field) and does not validate `project_id`/`name` when provided.
- `feed_permissions` and `feed_retention_policies` use index-based `for_each`, causing unstable plans on reordering.
- No validation that `feed_key` references an existing feed; errors are deferred to plan/apply.
- `feed_id`/`feed_key` are not validated as non-empty strings when set.
- `project_id` for permissions/retention is not derived from feed data when `feed_key` is used.
- Missing `docs/IMPORT.md` for the module.
- README Terraform docs are not generated.

## Target Module Design

### Inputs (Feeds)

- feeds (map(object)):
  - name (optional string; defaults to map key)
  - project_id (optional string)
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
  - feed_key (optional string)
  - identity_descriptor (string)
  - role (string: reader, contributor, collaborator, administrator)
  - project_id (optional string)
  - display_name (optional string)

Validation rules:
- Exactly one of feed_id or feed_key.
- feed_id/feed_key must be non-empty when provided.
- feed_key must exist in var.feeds (when used).
- Unique key across entries (coalesce key, feed_key, feed_id, identity_descriptor).

Behavior:
- If feed_key is set and project_id is omitted, derive project_id from the feed.
- Normalize role to lowercase before sending to provider.

### Inputs (Feed Retention Policies)

- feed_retention_policies (list(object)):
  - key (optional string) for stable for_each
  - feed_id (optional string)
  - feed_key (optional string)
  - count_limit (number > 0)
  - days_to_keep_recently_downloaded_packages (number > 0)
  - project_id (optional string)

Validation rules:
- Exactly one of feed_id or feed_key.
- feed_id/feed_key must be non-empty when provided.
- feed_key must exist in var.feeds (when used).
- Unique key across entries (coalesce key, feed_key, feed_id).

Behavior:
- If feed_key is set and project_id is omitted, derive project_id from the feed.

### Outputs

- feed_ids (map, keyed by feed key)
- feed_names (map, keyed by feed key)
- feed_project_ids (map, keyed by feed key)
- optional: permission_ids/retention_policy_ids if needed downstream

## Examples

Update examples to show stable key usage and derived project_id:
- basic: single feed only.
- complete: feed + permissions + retention using feed_key (without project_id duplication).
- secure: feed with reader permissions + stricter retention.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - feed description validation.
  - feed_key existence validation for permissions/retention.
  - unique key validation for permissions/retention.
  - role normalization and allowed values.
- Integration:
  - feed + permissions + retention with derived project_id.
- Negative:
  - invalid feed_key reference.
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

- [ ] Update variables.tf with description, key fields, and validation rules.
- [ ] Refactor main.tf for stable for_each, role normalization, and project_id derivation.
- [ ] Update outputs.tf if additional outputs are added.
- [ ] Add docs/IMPORT.md and regenerate README (terraform-docs).
- [ ] Update examples (basic/complete/secure) for the new interface.
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] make docs + update examples list.
