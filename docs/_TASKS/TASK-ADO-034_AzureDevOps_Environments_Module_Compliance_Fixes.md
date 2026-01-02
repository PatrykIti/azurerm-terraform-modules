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

## Proposed Variables.tf Shape (Draft)

```hcl
# Core
variable "project_id" { ... }
variable "name" { ... }
variable "description" { ... }

variable "kubernetes_resources" {
  description = "Kubernetes resources attached to the environment."
  type = list(object({
    name                = string
    service_endpoint_id = string
    namespace           = string
    cluster_name        = optional(string)
    tags                = optional(list(string))
  }))
  default = []
}

# All checks require name for stable keys. target_resource_type defaults to "environment".
# target_resource_name is only allowed when targeting environmentResource and must reference
# kubernetes_resources[*].name. If there is exactly one Kubernetes resource, target_resource_name
# may be omitted and the module will target that single resource.

variable "check_approvals" {
  type = list(object({
    name                 = string
    target_resource_type = optional(string, "environment")
    target_resource_name = optional(string)
    approvers            = list(string)
    instructions         = optional(string)
    minimum_required_approvers = optional(number)
    requester_can_approve      = optional(bool)
    timeout                   = optional(number)
  }))
  default = []
}

variable "check_branch_controls" {
  type = list(object({
    name                 = string
    target_resource_type = optional(string, "environment")
    target_resource_name = optional(string)
    allowed_branches                 = optional(string)
    verify_branch_protection         = optional(bool)
    ignore_unknown_protection_status = optional(bool)
    timeout                          = optional(number)
  }))
  default = []
}

variable "check_business_hours" {
  type = list(object({
    name                 = string
    target_resource_type = optional(string, "environment")
    target_resource_name = optional(string)
    start_time = string
    end_time   = string
    time_zone  = string
    monday     = optional(bool)
    tuesday    = optional(bool)
    wednesday  = optional(bool)
    thursday   = optional(bool)
    friday     = optional(bool)
    saturday   = optional(bool)
    sunday     = optional(bool)
    timeout    = optional(number)
  }))
  default = []
}

variable "check_exclusive_locks" {
  type = list(object({
    name                 = string
    target_resource_type = optional(string, "environment")
    target_resource_name = optional(string)
    timeout              = optional(number)
  }))
  default = []
}

variable "check_required_templates" {
  type = list(object({
    name                 = string
    target_resource_type = optional(string, "environment")
    target_resource_name = optional(string)
    required_templates = list(object({
      template_path   = string
      repository_name = string
      repository_ref  = string
      repository_type = optional(string)
    }))
  }))
  default = []
}

variable "check_rest_apis" {
  type = list(object({
    name                 = string
    target_resource_type = optional(string, "environment")
    target_resource_name = optional(string)
    connected_service_name_selector = string
    connected_service_name          = string
    method                          = string
    body                            = optional(string)
    headers                         = optional(string)
    retry_interval                  = optional(number)
    success_criteria                = optional(string)
    url_suffix                      = optional(string)
    variable_group_name             = optional(string)
    completion_event                = optional(string)
    timeout                         = optional(string)
  }))
  default = []
}
```

Validation rules (summary):
- All `name` fields are required and unique per list.
- `target_resource_type` in ["environment", "environmentResource"].
- When `target_resource_type = "environmentResource"`:
  - if `length(kubernetes_resources) == 1`, `target_resource_name` may be omitted (auto-target the single resource).
  - if `length(kubernetes_resources) > 1`, `target_resource_name` is required and must match a name in `kubernetes_resources`.
- Disallow external environment IDs in all inputs.

## Proposed Main.tf Shape (Draft)

```hcl
resource "azuredevops_environment" "environment" {
  project_id  = var.project_id
  name        = var.name
  description = var.description
}

resource "azuredevops_environment_resource_kubernetes" "environment_resource_kubernetes" {
  for_each = { for resource in var.kubernetes_resources : resource.name => resource }

  project_id          = var.project_id
  environment_id      = azuredevops_environment.environment.id
  service_endpoint_id = each.value.service_endpoint_id
  name                = each.value.name
  namespace           = each.value.namespace
  cluster_name        = each.value.cluster_name
  tags                = each.value.tags
}

resource "azuredevops_check_approval" "check_approval" {
  for_each = { for check in var.check_approvals : check.name => check }

  project_id           = var.project_id
  target_resource_type = each.value.target_resource_type
  target_resource_id = each.value.target_resource_type == "environment" ? (
    azuredevops_environment.environment.id
  ) : (
    each.value.target_resource_name != null ? (
      azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.target_resource_name].id
    ) : (
      azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[
        one(keys(azuredevops_environment_resource_kubernetes.environment_resource_kubernetes))
      ].id
    )
  )
  approvers                  = each.value.approvers
  instructions               = each.value.instructions
  minimum_required_approvers = each.value.minimum_required_approvers
  requester_can_approve      = each.value.requester_can_approve
  timeout                    = each.value.timeout
}

resource "azuredevops_check_branch_control" "check_branch_control" {
  for_each = { for check in var.check_branch_controls : check.name => check }

  project_id           = var.project_id
  display_name         = each.value.name
  target_resource_type = each.value.target_resource_type
  target_resource_id = each.value.target_resource_type == "environment" ? (
    azuredevops_environment.environment.id
  ) : (
    each.value.target_resource_name != null ? (
      azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.target_resource_name].id
    ) : (
      azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[
        one(keys(azuredevops_environment_resource_kubernetes.environment_resource_kubernetes))
      ].id
    )
  )
  allowed_branches                 = each.value.allowed_branches
  verify_branch_protection         = each.value.verify_branch_protection
  ignore_unknown_protection_status = each.value.ignore_unknown_protection_status
  timeout                          = each.value.timeout
}

# Repeat the same target resolution pattern for:
# - azuredevops_check_business_hours (display_name = name)
# - azuredevops_check_exclusive_lock
# - azuredevops_check_required_template
# - azuredevops_check_rest_api (display_name = name)
```

## Proposed Outputs.tf Shape (Draft)

```hcl
output "environment_id" {
  description = "ID of the Azure DevOps environment managed by this module."
  value       = azuredevops_environment.environment.id
}

output "kubernetes_resource_ids" {
  description = "Map of Kubernetes resource IDs keyed by resource name."
  value = {
    for key, resource in azuredevops_environment_resource_kubernetes.environment_resource_kubernetes :
    key => resource.id
  }
}

output "check_ids" {
  description = "Map of check IDs grouped by check type and keyed by name."
  value = {
    approvals = { for key, check in azuredevops_check_approval.check_approval : key => check.id }
    branch_controls = { for key, check in azuredevops_check_branch_control.check_branch_control : key => check.id }
    business_hours = { for key, check in azuredevops_check_business_hours.check_business_hours : key => check.id }
    exclusive_locks = { for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock : key => check.id }
    required_templates = { for key, check in azuredevops_check_required_template.check_required_template : key => check.id }
    rest_apis = { for key, check in azuredevops_check_rest_api.check_rest_api : key => check.id }
  }
}
```

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
