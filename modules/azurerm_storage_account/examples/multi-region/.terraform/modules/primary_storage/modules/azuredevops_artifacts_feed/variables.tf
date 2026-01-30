# -----------------------------------------------------------------------------
# Feed
# -----------------------------------------------------------------------------

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

variable "features" {
  description = "Feed feature flags for azuredevops_feed.features. Set to null to leave unmanaged."
  type = object({
    permanent_delete = optional(bool)
    restore          = optional(bool)
  })
  default = null
}

# -----------------------------------------------------------------------------
# Feed Permissions
# -----------------------------------------------------------------------------

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
      for perm in var.feed_permissions : (
        perm.key == null || length(trimspace(perm.key)) > 0
      )
    ])
    error_message = "feed_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : (
        perm.display_name == null || length(trimspace(perm.display_name)) > 0
      )
    ])
    error_message = "feed_permissions.display_name must be a non-empty string when provided."
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
      for perm in var.feed_permissions :
      coalesce(perm.key, perm.identity_descriptor)
    ])) == length(var.feed_permissions)
    error_message = "feed_permissions must have unique keys (key or identity_descriptor)."
  }
}

# -----------------------------------------------------------------------------
# Feed Retention Policies
# -----------------------------------------------------------------------------

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
      for policy in var.feed_retention_policies : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
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
        format(
          "%s-%s",
          policy.count_limit,
          policy.days_to_keep_recently_downloaded_packages
        )
      )
    ])) == length(var.feed_retention_policies)
    error_message = "feed_retention_policies must have unique keys (key or count_limit/days_to_keep_recently_downloaded_packages)."
  }
}
