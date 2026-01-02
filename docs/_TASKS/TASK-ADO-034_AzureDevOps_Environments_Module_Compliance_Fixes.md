# TASK-ADO-034: Azure DevOps Environments Module Compliance Fixes
# FileName: TASK-ADO-034_AzureDevOps_Environments_Module_Compliance_Fixes.md

**Priority:** High
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-017
**Status:** To Do

---

## Overview

Align `modules/azuredevops_environments` with module standards for subresource scoping, stable keys, and docs accuracy. Enforce that all subresources depend on the module-managed environment only, reduce fallback logic in locals, and refresh module docs and examples.

## Current Gaps

- Subresources allow external environment IDs via `kubernetes_resources.environment_id` and `check_*.*target_resource_id`, violating the rule that subresources must depend on the module `azuredevops_environment`.
- `coalesce` is used for `target_resource_id` and `target_resource_type` defaults in `main.tf`; this should be handled via input defaults and validation instead.
- for_each keys rely on `coalesce(..., target_resource_id)` instead of stable name/display_name or required keys; approvals, exclusive locks, and required templates lack a required key.
- No internal reference path exists to target module-created environment resources (kubernetes) without passing raw IDs.
- Resource local name for `azuredevops_environment_resource_kubernetes` does not match the resource type naming convention.
- Example README terraform-docs sections are stale relative to example `main.tf` (module source and provider details).
- `.terraform` and `.terraform.lock.hcl` artifacts are present in the module root.
- `SECURITY.md` does not reference the secure example as required by the examples guide.
- `VERSIONING.md` references AzureRM provider versions instead of Azure DevOps provider versions.

## Scope

- `modules/azuredevops_environments/main.tf`
- `modules/azuredevops_environments/variables.tf`
- `modules/azuredevops_environments/outputs.tf`
- `modules/azuredevops_environments/README.md`
- `modules/azuredevops_environments/docs/README.md`
- `modules/azuredevops_environments/docs/IMPORT.md`
- `modules/azuredevops_environments/tests/*`
- `modules/azuredevops_environments/examples/*/README.md`
- `modules/azuredevops_environments/SECURITY.md`
- `modules/azuredevops_environments/VERSIONING.md`

## Docs to Update

In-module:
- `modules/azuredevops_environments/SECURITY.md`
- `modules/azuredevops_environments/VERSIONING.md`
- `modules/azuredevops_environments/README.md`
- `modules/azuredevops_environments/docs/README.md`
- `modules/azuredevops_environments/docs/IMPORT.md`
- `modules/azuredevops_environments/examples/basic/README.md`
- `modules/azuredevops_environments/examples/complete/README.md`
- `modules/azuredevops_environments/examples/secure/README.md`

Outside module:
- `docs/_TASKS/README.md`

## Acceptance Criteria

- Subresources always depend on `azuredevops_environment` and cannot target external environments.
- Inputs no longer accept external environment IDs; validations provide explicit errors and guidance.
- for_each keys use stable name/display_name or required key fields (no target_resource_id fallback).
- Defaults for `target_resource_type` are defined in input schema, removing `coalesce` from resource arguments.
- Module root no longer contains `.terraform/` or `.terraform.lock.hcl`.
- `azuredevops_environment_resource_kubernetes` local name matches the resource type and references are updated consistently.
- Example README terraform-docs sections match their `main.tf` (providers and module source).
- `SECURITY.md` links to or references the secure example.
- `VERSIONING.md` reflects Azure DevOps provider versioning and removes AzureRM-only content.

## Implementation Checklist

- [ ] Remove `.terraform/` and `.terraform.lock.hcl` from `modules/azuredevops_environments` and add to ignore list if needed.
- [ ] Remove external environment ID inputs or gate them with validation; introduce module-scoped references for checks targeting kubernetes resources.
- [ ] Define `target_resource_type` defaults in `variables.tf` and remove `coalesce` from resource arguments where possible.
- [ ] Require stable keys for check types without display_name; use name/display_name for other for_each keys.
- [ ] Rename the Kubernetes environment resource local name and update references in outputs, tests, README, and import docs.
- [ ] Regenerate terraform-docs for examples and verify README alignment.
- [ ] Add a secure example reference to `SECURITY.md`.
- [ ] Update `VERSIONING.md` provider matrix and examples to Azure DevOps context.
