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
  description = "Kubernetes resources attached to the environment (checks can be nested per resource)."
  type = list(object({
    name                = string
    service_endpoint_id = string
    namespace           = string
    cluster_name        = optional(string)
    tags                = optional(list(string))
    checks = optional(object({
      approvals = optional(list(object({
        name                        = string
        approvers                  = list(string)
        instructions               = optional(string)
        minimum_required_approvers = optional(number)
        requester_can_approve      = optional(bool)
        timeout                    = optional(number)
      })), [])
      branch_controls = optional(list(object({
        name                             = string
        allowed_branches                 = optional(string)
        verify_branch_protection         = optional(bool)
        ignore_unknown_protection_status = optional(bool)
        timeout                          = optional(number)
      })), [])
      business_hours = optional(list(object({
        name       = string
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
      })), [])
      exclusive_locks = optional(list(object({
        name    = string
        timeout = optional(number)
      })), [])
      required_templates = optional(list(object({
        name = string
        required_templates = list(object({
          template_path   = string
          repository_name = string
          repository_ref  = string
          repository_type = optional(string)
        }))
      })), [])
      rest_apis = optional(list(object({
        name                             = string
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
      })), [])
    }), {})
  }))
  default = []
}

# Environment-level checks (apply to azuredevops_environment).
# All checks require name for stable keys.
variable "check_approvals" {
  type = list(object({
    name                        = string
    approvers                  = list(string)
    instructions               = optional(string)
    minimum_required_approvers = optional(number)
    requester_can_approve      = optional(bool)
    timeout                    = optional(number)
  }))
  default = []
}

variable "check_branch_controls" {
  type = list(object({
    name                             = string
    allowed_branches                 = optional(string)
    verify_branch_protection         = optional(bool)
    ignore_unknown_protection_status = optional(bool)
    timeout                          = optional(number)
  }))
  default = []
}

variable "check_business_hours" {
  type = list(object({
    name       = string
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
    name    = string
    timeout = optional(number)
  }))
  default = []
}

variable "check_required_templates" {
  type = list(object({
    name = string
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
    name                             = string
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
- `kubernetes_resources[*].name` is required and unique.
- All `name` fields are required and unique per list (root checks and nested checks per resource).
- Nested checks are allowed only under `kubernetes_resources[*].checks` and always target that resource.
- Root-level checks always target the environment resource.
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

# Environment-level checks
resource "azuredevops_check_approval" "check_approval_environment" {
  for_each = { for check in var.check_approvals : check.name => check }

  project_id           = var.project_id
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environment.id
  approvers                  = each.value.approvers
  instructions               = each.value.instructions
  minimum_required_approvers = each.value.minimum_required_approvers
  requester_can_approve      = each.value.requester_can_approve
  timeout                    = each.value.timeout
}

resource "azuredevops_check_branch_control" "check_branch_control_environment" {
  for_each = { for check in var.check_branch_controls : check.name => check }

  project_id           = var.project_id
  display_name         = each.value.name
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environment.id
  allowed_branches                 = each.value.allowed_branches
  verify_branch_protection         = each.value.verify_branch_protection
  ignore_unknown_protection_status = each.value.ignore_unknown_protection_status
  timeout                          = each.value.timeout
}

# Kubernetes-level checks (per resource)
resource "azuredevops_check_branch_control" "check_branch_control_kubernetes" {
  for_each = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.branch_controls, []) : {
          resource_name = resource.name
          check         = check
        }
      ]
    ]) : "${item.resource_name}:${item.check.name}" => item
  }

  project_id           = var.project_id
  display_name         = each.value.check.name
  target_resource_type = "environmentResource"
  target_resource_id   = azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id
  allowed_branches                 = each.value.check.allowed_branches
  verify_branch_protection         = each.value.check.verify_branch_protection
  ignore_unknown_protection_status = each.value.check.ignore_unknown_protection_status
  timeout                          = each.value.check.timeout
}

# Repeat the same pattern for other check types:
# - approvals, business_hours, exclusive_locks, required_templates, rest_apis
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
  description = "Map of check IDs grouped by target (environment vs kubernetes resources)."
  value = {
    environment = {
      approvals = { for key, check in azuredevops_check_approval.check_approval_environment : key => check.id }
      branch_controls = { for key, check in azuredevops_check_branch_control.check_branch_control_environment : key => check.id }
      business_hours = { for key, check in azuredevops_check_business_hours.check_business_hours_environment : key => check.id }
      exclusive_locks = { for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock_environment : key => check.id }
      required_templates = { for key, check in azuredevops_check_required_template.check_required_template_environment : key => check.id }
      rest_apis = { for key, check in azuredevops_check_rest_api.check_rest_api_environment : key => check.id }
    }
    kubernetes_resources = {
      for resource_name in keys(azuredevops_environment_resource_kubernetes.environment_resource_kubernetes) :
      resource_name => {
        approvals = {
          for key, check in azuredevops_check_approval.check_approval_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        branch_controls = {
          for key, check in azuredevops_check_branch_control.check_branch_control_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        business_hours = {
          for key, check in azuredevops_check_business_hours.check_business_hours_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        exclusive_locks = {
          for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        required_templates = {
          for key, check in azuredevops_check_required_template.check_required_template_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        rest_apis = {
          for key, check in azuredevops_check_rest_api.check_rest_api_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
      }
    }
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
- Kubernetes checks are nested under `kubernetes_resources[*].checks` and always target that resource; root-level checks target the environment only.
- Inputs no longer accept external environment IDs; validations provide explicit errors and guidance.
- for_each keys use stable `name` (and `display_name = name` where required), with no target-based fallbacks.
- Target resolution is implicit by placement (root vs nested), removing `target_resource_type`/`target_resource_id` inputs and `coalesce` defaults.
- Module root no longer contains `.terraform/` or `.terraform.lock.hcl`.
- `azuredevops_environment_resource_kubernetes` local name matches the resource type and references are updated consistently.
- Example README terraform-docs sections match their `main.tf` (providers and module source).
- `SECURITY.md` links to or references the secure example.
- `VERSIONING.md` reflects Azure DevOps provider versioning and removes AzureRM-only content.

## Implementation Checklist

- [ ] Remove `.terraform/` and `.terraform.lock.hcl` from `modules/azuredevops_environments` and add to ignore list if needed.
- [ ] Remove external environment ID inputs and move Kubernetes checks under `kubernetes_resources[*].checks`; keep root checks for environment-only.
- [ ] Update check resources to target environment or kubernetes implicitly (no `target_resource_type`/`target_resource_id` inputs).
- [ ] Require stable `name` keys for all checks; map `display_name = name` where needed.
- [ ] Update outputs to group environment vs kubernetes checks by resource name.
- [ ] Rename the Kubernetes environment resource local name and update references in outputs, tests, README, and import docs.
- [ ] Regenerate terraform-docs for examples and verify README alignment.
- [ ] Add a secure example reference to `SECURITY.md`.
- [ ] Update `VERSIONING.md` provider matrix and examples to Azure DevOps context.
