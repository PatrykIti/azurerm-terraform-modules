# TASK-ADO-024: Azure DevOps Service Hooks Module Refactor
# FileName: TASK-ADO-024_AzureDevOps_ServiceHooks_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-012
**Status:** ✅ **Done** (2025-12-28)

---

## Overview

Refactor `modules/azuredevops_servicehooks` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
Focus on stable `for_each` keys, stricter validation, and secure handling of sensitive inputs.
Document any deviations required by resource-specific constraints.
The main service hook resource must be a single (non-iterated) block with flat inputs; for multiple hooks use module-level `for_each`.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_servicehook_webhook_tfs`
- `azuredevops_servicehook_storage_queue_pipelines`
- `azuredevops_servicehook_permissions`

## Current Gaps (Summary)

- `webhooks` and `storage_queue_hooks` are modeled as lists and iterated; should be single resources with module-level `for_each`.
- `webhooks`, `storage_queue_hooks`, and `servicehook_permissions` use index-based `for_each`, causing unstable addressing on reorder.
- No explicit `key` inputs or uniqueness validation for list resources; outputs are keyed by list index.
- `servicehook_permissions` does not validate permissions map values or ensure non-empty permissions; `project_id` is not validated when provided.
- `storage_queue_hooks` lacks numeric validation for `ttl`/visibility timeout, and `webhooks` lacks non-empty validation for some required fields (e.g., tfvc_checkin.path).
- Secret fields (`account_key`, `basic_auth_password`) are not marked sensitive or documented.
- Missing `docs/IMPORT.md` for the module.
- README/examples do not demonstrate stable keys (and Terraform docs are not generated).

## Target Module Design

### Inputs (Webhook)

`webhook` (object):
- url (string, required)
- accept_untrusted_certs (optional bool)
- basic_auth_username (optional string)
- basic_auth_password (optional string, sensitive)
- http_headers (optional map(string))
- resource_details_to_send (optional string)
- messages_to_send (optional string)
- detailed_messages_to_send (optional string)

Event blocks (exactly one, same as today):
- build_completed, git_pull_request_commented, git_pull_request_created,
  git_pull_request_merge_attempted, git_pull_request_updated, git_push,
  repository_created, repository_deleted, repository_forked, repository_renamed,
  repository_status_changed, service_connection_created, service_connection_updated,
  tfvc_checkin, work_item_commented, work_item_created, work_item_deleted,
  work_item_restored, work_item_updated.

Validation rules:
- url must be non-empty.
- Exactly one event block is set.
- tfvc_checkin.path must be non-empty.
- Validate enumerated fields per provider docs (resource_details_to_send/messages_to_send/detailed_messages_to_send).

### Inputs (Storage Queue Hook)

`storage_queue_hook` (object):
- account_name (string, required)
- account_key (string, required, sensitive)
- queue_name (string, required)
- ttl (optional number, >= 0)
- visibility_timeout / visi_timeout (optional number, >= 0; align name with provider)
- run_state_changed_event (optional object)
- stage_state_changed_event (optional object)

Validation rules:
- account_name/account_key/queue_name must be non-empty.
- Exactly one of run_state_changed_event or stage_state_changed_event.
- ttl and visibility timeout must be >= 0 when provided.

### Inputs (Service Hook Permissions)

`servicehook_permissions` (list(object)):
- key (optional string) for stable for_each
- project_id (optional string, defaults to module project_id)
- principal (string, required)
- permissions (map(string), required)
- replace (optional bool, default true)

Validation rules:
- principal must be non-empty.
- project_id must be non-empty when provided.
- permissions map must be non-empty.
- permissions values must be one of Allow/Deny/NotSet (normalize case if needed).
- Unique keys using `coalesce(key, principal)`.

### Locals / Implementation

- Build normalized maps in `locals` for the permissions list using computed keys.
- Use the normalized maps for `for_each` to ensure stable resource addressing.
- Normalize permission values before sending to the provider if required.

### Outputs

- `webhook_id` (string, when configured)
- `storage_queue_hook_id` (string, when configured)
- `servicehook_permission_ids` (map, keyed by permission key).

## Examples

Update examples to show stable key usage:
- basic: single webhook.
- complete: webhook + storage queue hook with event filters (show module-level `for_each` for multiple hooks).
- secure: filtered webhook + permissions with limited permission set.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - event block validation (exactly one).
  - unique key validation for permissions list.
  - permissions values allowed + non-empty map.
  - ttl/visibility timeout non-negative validation.
- Integration:
  - create webhook + storage queue hook + permissions.
- Negative:
  - duplicate key in permissions.
  - invalid permission value.
  - ttl/visibility timeout < 0.

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-servicehooks-refactor.md`

## Acceptance Criteria

- Module follows MODULE_GUIDE and TERRAFORM_BEST_PRACTICES with stable `for_each` keys and validations.
- Inputs cover provider-required fields with explicit validation and secure handling of secrets.
- Outputs are keyed by stable, human-readable keys; permission IDs are available.
- README + examples + docs/IMPORT.md updated and generated.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [ ] Replace webhook/storage queue lists with single objects and add validations.
- [ ] Add optional `key` to permissions list and update validations/uniqueness.
- [ ] Refactor `main.tf` to use normalized maps and stable `for_each` keys for permissions.
- [ ] Tighten validation for permissions and numeric fields; align `visi_timeout` naming with provider docs.
- [ ] Mark sensitive inputs and update README guidance.
- [ ] Update outputs (stable keys + permission IDs).
- [ ] Update examples and tests (fixtures, unit, terratest).
- [ ] Add `docs/IMPORT.md`.
- [ ] Run docs generation and update README.
