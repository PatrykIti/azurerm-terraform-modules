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

- Feed creation is conditional (`count`) to allow a permissions/retention-only mode, which conflicts with "no conditional creation".
- `name`/`project_id` are nullable and optional, which permits a no-op module run and external `feed_id` usage.
- `feed_permissions` and `feed_retention_policies` accept `feed_id`/`project_id`, enabling management of subresources outside the module feed.
- Feed input lacks `description` (provider field).
- README/example docs need regeneration after the interface change.

## Target Module Design

### Inputs (Feed)

Flat variables for the main feed (single resource):
- name (string, required, non-null)
- project_id (string, required, non-null)
- description (optional string, non-empty if set)
- features (optional object with permanent_delete, restore)
- verify provider schema for any additional optional fields and add if applicable

Validation rules:
- name and project_id must be non-empty strings and non-null.
- description must be non-empty when provided.

### Inputs (Feed Permissions)

- feed_permissions (list(object)):
  - key (optional string) for stable for_each
  - identity_descriptor (string)
  - role (string: reader, contributor, collaborator, administrator)
  - display_name (optional string)

Validation rules:
- Unique key across entries (coalesce key, identity_descriptor).

Behavior:
- Normalize role to lowercase before sending to provider.
- Always attach permissions to the module-managed feed.

### Inputs (Feed Retention Policies)

- feed_retention_policies (list(object)):
  - key (optional string) for stable for_each
  - count_limit (number > 0)
  - days_to_keep_recently_downloaded_packages (number > 0)

Validation rules:
- Unique key across entries (coalesce key, count_limit, days_to_keep_recently_downloaded_packages).

Behavior:
- Always attach retention policies to the module-managed feed.

### Outputs

- feed_id (string)
- feed_name (string)
- feed_project_id (string)
- optional: permission_ids/retention_policy_ids if needed downstream

---

## Implementation Sketch (by file)

These snippets make the intended changes explicit.

### variables.tf

```hcl
variable "name" {
  description = "The name of the Azure DevOps feed."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "project_id" {
  description = "The Azure DevOps project ID to scope the feed."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

variable "description" {
  description = "Optional description for the Azure DevOps feed."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(trimspace(var.description)) > 0
    error_message = "description must be a non-empty string when provided."
  }
}

variable "features" {
  description = "Feed feature flags for azuredevops_feed.features. Set to null to leave unmanaged."
  type = object({
    permanent_delete = optional(bool)
    restore          = optional(bool)
  })
  default = null
}

variable "feed_permissions" {
  description = "List of feed permissions to assign."
  type = list(object({
    key                 = optional(string)
    identity_descriptor = string
    role                = string
    display_name        = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.feed_permissions :
      perm.key == null || length(trimspace(perm.key)) > 0
    ])
    error_message = "feed_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : length(trimspace(perm.identity_descriptor)) > 0
    ])
    error_message = "feed_permissions.identity_descriptor must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : contains([
        "reader",
        "contributor",
        "collaborator",
        "administrator",
      ], lower(perm.role))
    ])
    error_message = "feed_permissions.role must be reader, contributor, collaborator, or administrator."
  }

  validation {
    condition = length(distinct([
      for perm in var.feed_permissions : coalesce(perm.key, perm.identity_descriptor)
    ])) == length(var.feed_permissions)
    error_message = "feed_permissions must have unique keys (key or identity_descriptor)."
  }
}

variable "feed_retention_policies" {
  description = "List of feed retention policies to manage."
  type = list(object({
    key                                       = optional(string)
    count_limit                               = number
    days_to_keep_recently_downloaded_packages = number
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies :
      policy.key == null || length(trimspace(policy.key)) > 0
    ])
    error_message = "feed_retention_policies.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies : policy.count_limit > 0
    ])
    error_message = "feed_retention_policies.count_limit must be greater than zero."
  }

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies : policy.days_to_keep_recently_downloaded_packages > 0
    ])
    error_message = "feed_retention_policies.days_to_keep_recently_downloaded_packages must be greater than zero."
  }

  validation {
    condition = length(distinct([
      for policy in var.feed_retention_policies :
      coalesce(
        policy.key,
        format("%s-%s", policy.count_limit, policy.days_to_keep_recently_downloaded_packages)
      )
    ])) == length(var.feed_retention_policies)
    error_message = "feed_retention_policies must have unique keys (key or count_limit/days_to_keep_recently_downloaded_packages)."
  }
}
```

### main.tf

```hcl
locals {
  # Normalize list inputs into stable maps for for_each addressing.
  feed_permissions = {
    for permission in var.feed_permissions :
    coalesce(permission.key, permission.identity_descriptor) => permission
  }
  # Ensure retention policy resources keep stable addresses across reorders.
  feed_retention_policies = {
    for policy in var.feed_retention_policies :
    coalesce(
      policy.key,
      format("%s-%s", policy.count_limit, policy.days_to_keep_recently_downloaded_packages)
    ) => policy
  }
}

resource "azuredevops_feed" "feed" {
  name        = var.name
  project_id  = var.project_id
  description = var.description

  dynamic "features" {
    for_each = var.features == null ? [] : [var.features]
    content {
      permanent_delete = try(features.value.permanent_delete, null)
      restore          = try(features.value.restore, null)
    }
  }
}

resource "azuredevops_feed_permission" "feed_permission" {
  for_each = local.feed_permissions

  feed_id             = azuredevops_feed.feed.id
  identity_descriptor = each.value.identity_descriptor
  role                = lower(each.value.role)
  project_id          = var.project_id
  display_name        = try(each.value.display_name, null)
}

resource "azuredevops_feed_retention_policy" "feed_retention_policy" {
  for_each = local.feed_retention_policies

  feed_id                                   = azuredevops_feed.feed.id
  count_limit                               = each.value.count_limit
  days_to_keep_recently_downloaded_packages = each.value.days_to_keep_recently_downloaded_packages
  project_id                                = var.project_id
}
```

### outputs.tf

```hcl
output "feed_id" {
  description = "The ID of the Azure DevOps feed."
  value       = azuredevops_feed.feed.id
}

output "feed_name" {
  description = "The name of the Azure DevOps feed."
  value       = azuredevops_feed.feed.name
}

output "feed_project_id" {
  description = "The project ID associated with the Azure DevOps feed."
  value       = azuredevops_feed.feed.project_id
}
```

## Examples

Update examples to show stable key usage and module-owned feed:
- basic: single feed only.
- complete: feed + permissions + retention attached to module feed.
- secure: feed with reader permissions + stricter retention.

## Tests

Update tests per TESTING_GUIDE:

- Unit:
  - name/project_id required + non-empty validation.
  - description validation.
  - unique key validation for permissions/retention.
  - role normalization and allowed values.
- Integration:
  - feed + permissions + retention attached to module feed.
- Negative:
  - duplicate key in permissions/retention list.
  - invalid retention limits.
  - invalid role values.

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

- [ ] Update variables.tf: require name/project_id, add description, remove feed_id/project_id from subresource inputs.
- [ ] Refactor main.tf to remove conditional creation, remove create_feed locals, and attach subresources to module feed.
- [ ] Update outputs.tf to reference the single feed resource directly.
- [ ] Add docs/IMPORT.md and regenerate README (terraform-docs).
- [ ] Extend docs/IMPORT.md with key-derivation examples (key vs fallback) and matching import addresses.
- [ ] Add short, explicit comments above locals in main.tf to explain stable for_each keys.
- [ ] Update examples (basic/complete/secure) for the new interface.
- [ ] Update tests (fixtures, unit, terratest, test_config).
- [ ] make docs + update examples list.
