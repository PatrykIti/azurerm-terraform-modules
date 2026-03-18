# TASK-ADO-017: Azure DevOps Environments Module Refactor
# FileName: TASK-ADO-017_AzureDevOps_Environments_Module_Refactor.md

**Priority:** 🔴 High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-008
**Status:** ✅ **Done** (2025-12-28)

---

## Overview

Refactor `modules/azuredevops_environments` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES.
The main `azuredevops_environment` must be a single (non-iterated) resource with flat inputs.
Sub-resources and checks should use list(object) with stable for_each keys; for multiple environments use module-level for_each in the consuming environment configuration.

## Updated Rules (Re-opened)

- Main resource is single (non-iterated); use module-level `for_each` in environment config to manage multiple instances.
- Prefer `list(object)` for collections; use `map` only when provider requires key/value semantics.
- Use simple, stable `for_each` keys based on unique fields (name, principal_id, service_principal_id, group_name, etc.); never index-based.
- Follow docs/MODULE_GUIDE/, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md.

## Scope (Provider Resources)

- `azuredevops_environment`
- `azuredevops_environment_resource_kubernetes`
- `azuredevops_check_approval`
- `azuredevops_check_branch_control`
- `azuredevops_check_business_hours`
- `azuredevops_check_exclusive_lock`
- `azuredevops_check_required_template`
- `azuredevops_check_rest_api`

## Current Gaps (Summary)

- `azuredevops_environment` is iterated over `var.environments` (map); core inputs are nested, not flat.
- `kubernetes_resources` and `check_*` use index-based for_each, leading to unstable resource addresses.
- Outputs for resources/checks are keyed by index instead of stable keys.
- `target_environment_key` lookups can resolve to null without validation if the key does not exist.
- Checks require `target_resource_id` or `target_environment_key` (no default to module environment).
- No `key` fields for list items; uniqueness and stable key validation are missing.
- Examples use random names (violates fixed-name examples rule).
- Missing `docs/IMPORT.md` for the module.
- `target_resource_type` has no allowed-values validation.

## Target Module Design

### Inputs (Core Environment)

Flat variables for the main environment:
- name (string, required)
- description (string, optional)
- project_id (string, required)

### Inputs (Kubernetes Resources)

- kubernetes_resources (list(object)):
  - key (optional string) for stable for_each
  - environment_id (optional string) — when omitted, use module environment ID
  - service_endpoint_id (string, required)
  - name (string, required)
  - namespace (string, required)
  - cluster_name (optional string)
  - tags (optional list(string))

Validation rules:
- name/namespace must be non-empty strings
- for_each key = `coalesce(key, name)` with uniqueness validation
- if environment_id is omitted, module environment is required

### Inputs (Checks)

For each `check_*` list:
- key (optional string) for stable for_each
- target_resource_id (optional string) — default to module environment ID
- target_resource_type (optional string, default "environment")
- per-type fields as today

Validation rules:
- target_resource_type in ["environment", "environmentResource"]
- for_each keys derived from `coalesce(key, display_name, target_resource_id)` and must be unique
- approvals: approvers non-empty; minimum_required_approvers <= length(approvers)
- required_templates must contain at least one entry

### Outputs

- environment_id (string)
- kubernetes_resource_ids (map, keyed by resource key/name)
- check_ids (map of maps, keyed by check key)

## Examples

Update to show single environment usage with fixed names:
- basic: one environment
- complete: environment + Kubernetes resource + approvals/branch control
- secure: approvals + exclusive lock + business hours

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - name required validation
  - target_resource_type allowed values
  - stable key uniqueness for resources/checks
  - approvals minimum_required_approvers validation
- Integration:
  - create environment + Kubernetes resource + approval check
- Negative:
  - invalid target_resource_type
  - duplicate keys
  - missing required fields

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-ado-environments-refactor.md`

## Acceptance Criteria

- Module follows MODULE_GUIDE and TERRAFORM_BEST_PRACTICES (single env, flat inputs, stable keys).
- Sub-resources/checks can target module environment by default or external IDs when provided.
- Outputs keyed by stable, human-readable keys.
- Examples updated with fixed names; `docs/IMPORT.md` added.
- Unit + integration + negative tests updated and passing.

## Implementation Checklist

- [x] Refactor variables.tf: replace `environments` map with flat inputs; add optional `key` fields and validations.
- [x] Refactor main.tf: single `azuredevops_environment`; stable for_each for sub-resources/checks; default target IDs.
- [x] Update outputs.tf: stable maps and `environment_id` output.
- [x] Add `docs/IMPORT.md`.
- [x] Update examples (fixed names, remove random provider).
- [x] Update tests (fixtures, unit, terratest, test_config).
- [x] make docs + update README.

---

## Re-Verification (2026-02-14)

Task remained in To Do board column as re-opened marker, but module gate for `modules/azuredevops_environments` passed end-to-end:
- module `init` + `validate`
- examples `basic|complete|secure` `init` + `validate`
- `terraform test -test-directory=tests/unit`
- integration compile: `go test -c -run 'Test.*Integration' ./...` in `modules/azuredevops_environments/tests`

Evidence log:
- `/tmp/task_ado_017_checks_20260214_230757.log`

Board status moved to **Done**. Follow-up hardening remains tracked independently under `TASK-ADO-034`.
