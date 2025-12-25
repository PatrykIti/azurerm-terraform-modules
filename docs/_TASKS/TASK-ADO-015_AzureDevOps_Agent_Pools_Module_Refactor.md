# TASK-ADO-015: Azure DevOps Agent Pools Module Refactor
# FileName: TASK-ADO-015_AzureDevOps_Agent_Pools_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-004
**Status:** ✅ **Done** (2025-12-25)

---

## Overview

Refactor `modules/azuredevops_agent_pools` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
The main `azuredevops_agent_pool` resource must be a single (non-iterated) block with flat inputs.
`azuredevops_agent_queue` stays list(object) with stable for_each keys. `azuredevops_elastic_pool`
must also be a single (non-iterated) optional block; for multiple pools use module-level for_each.

## Scope (Provider Resources)

- `azuredevops_agent_pool`
- `azuredevops_agent_queue`
- `azuredevops_elastic_pool` (single optional block)

## Current Gaps (Summary)

- `azuredevops_agent_pool` is iterated via map (`agent_pools`) instead of a single resource.
- Core pool fields are nested in a map object; should be flat variables.
- `azuredevops_agent_queue` uses index-based for_each and always requires `name` (conflicts with provider rules).
- `azuredevops_elastic_pool` is missing required fields (service_endpoint_scope, desired_idle) and optional fields from provider docs.
- Resource local names are not aligned with naming rules (`pool`/`queue` vs `agent_pool`/`agent_queue`).
- Outputs for queues/elastic pools are keyed by index (should be name/key).
- Missing `docs/IMPORT.md` for the module.

## Target Module Design

### Inputs (Core Pool)

Flat variables for the main pool:
- name (string, required)
- auto_provision (bool, default false)
- auto_update (bool, default true)
- pool_type (string, default "automation"; allow "automation" or "deployment")

### Inputs (Queues)

- agent_queues (list(object)):
  - key (optional string) for stable for_each
  - project_id (string)
  - name (optional string) — provider allows name-only queue
  - agent_pool_id (optional string)

Validation rules:
- Provider rule: exactly one of `name` or `agent_pool_id` (not both).
- Module behavior: if both are omitted, set `agent_pool_id` to the module pool ID and do not set `name`.
- When `agent_pool_id` is specified, queue name is derived from the agent pool name (per provider behavior).
- for_each key = `coalesce(key, name, agent_pool_id)` with uniqueness validation (no index keys).

### Inputs (Elastic Pool)

Single optional object `elastic_pool` (no for_each):
- name (string, required)
- service_endpoint_id (string, required)
- service_endpoint_scope (string, required)
- azure_resource_id (string, required)
- desired_idle (number, required)
- max_capacity (number, required > 0)
- recycle_after_each_use (optional bool)
- time_to_live_minutes (optional number)
- agent_interactive_ui (optional bool)
- auto_provision (optional bool)
- auto_update (optional bool)
- project_id (optional string)

Validation rules:
- desired_idle >= 0 and <= max_capacity
- time_to_live_minutes >= 0 (if provided)

### Outputs

- agent_pool_id (string)
- agent_queue_ids (map, keyed by queue key/name)
- elastic_pool_id (string, when elastic_pool is set)

## Examples

Update examples to show single pool usage:
- basic: one pool + one queue (using module pool)
- complete: pool + multiple queues + elastic pool (single)
- secure: pool with auto_provision/auto_update disabled

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - pool_type validation
  - queue selector validation (name vs agent_pool_id)
  - elastic pool required fields (service_endpoint_scope, desired_idle)
  - unique key validation for queues
- Integration:
  - create pool + queue using module pool
  - elastic pool creation with required fields
- Negative:
  - invalid pool_type
  - queue with both name and agent_pool_id
  - elastic pool desired_idle > max_capacity

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-agent-pools-refactor.md`

## Acceptance Criteria

- Module follows MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (flat core inputs, non-iterated main resource).
- Provider requirements for `azuredevops_agent_queue` and `azuredevops_elastic_pool` are fully covered.
- Outputs are keyed by stable, human-readable keys.
- README + examples + docs/IMPORT.md updated.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [x] Refactor variables.tf: flatten pool inputs, update queue list(object) schema + validations, add optional elastic_pool object schema.
- [x] Refactor main.tf: single `azuredevops_agent_pool` block, for_each keyed by queue name or key, single optional `azuredevops_elastic_pool`.
- [x] Update outputs.tf: stable queue key maps, `agent_pool_id`, and `elastic_pool_id` output.
- [x] Update README + SECURITY + examples for new interface.
- [x] Add docs/IMPORT.md.
- [x] Update tests (fixtures, unit, terratest, test_config).
- [ ] make docs + update README.
