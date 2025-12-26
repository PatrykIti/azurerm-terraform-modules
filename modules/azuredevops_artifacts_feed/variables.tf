# -----------------------------------------------------------------------------
# Feeds
# -----------------------------------------------------------------------------

variable "feeds" {
  description = "Map of feeds to manage."
  type = map(object({
    name        = optional(string)
    project_id  = optional(string)
    description = optional(string)
    features = optional(object({
      permanent_delete = optional(bool)
      restore          = optional(bool)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for feed in values(var.feeds) : (
        feed.name == null || length(trimspace(feed.name)) > 0
      )
    ])
    error_message = "feeds.name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for feed in values(var.feeds) : (
        feed.project_id == null || length(trimspace(feed.project_id)) > 0
      )
    ])
    error_message = "feeds.project_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for feed in values(var.feeds) : (
        feed.description == null || length(trimspace(feed.description)) > 0
      )
    ])
    error_message = "feeds.description must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Feed Permissions
# -----------------------------------------------------------------------------

variable "feed_permissions" {
  description = "List of feed permissions to assign."
  type = list(object({
    key                 = optional(string)
    feed_id             = optional(string)
    feed_key            = optional(string)
    identity_descriptor = string
    role                = string
    project_id          = optional(string)
    display_name        = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : (
        (perm.feed_id != null) != (perm.feed_key != null)
      )
    ])
    error_message = "feed_permissions must set exactly one of feed_id or feed_key."
  }

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
        perm.feed_id == null || length(trimspace(perm.feed_id)) > 0
      )
    ])
    error_message = "feed_permissions.feed_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : (
        perm.feed_key == null || length(trimspace(perm.feed_key)) > 0
      )
    ])
    error_message = "feed_permissions.feed_key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : (
        perm.feed_key == null || contains(keys(var.feeds), perm.feed_key)
      )
    ])
    error_message = "feed_permissions.feed_key must reference a key in feeds."
  }

  validation {
    condition = alltrue([
      for perm in var.feed_permissions : (
        perm.project_id == null || length(trimspace(perm.project_id)) > 0
      )
    ])
    error_message = "feed_permissions.project_id must be a non-empty string when provided."
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
      coalesce(perm.key, perm.feed_key, perm.feed_id, perm.identity_descriptor)
    ])) == length(var.feed_permissions)
    error_message = "feed_permissions must have unique keys (key, feed_key, feed_id, or identity_descriptor)."
  }
}

# -----------------------------------------------------------------------------
# Feed Retention Policies
# -----------------------------------------------------------------------------

variable "feed_retention_policies" {
  description = "List of feed retention policies to manage."
  type = list(object({
    key                                       = optional(string)
    feed_id                                   = optional(string)
    feed_key                                  = optional(string)
    count_limit                               = number
    days_to_keep_recently_downloaded_packages = number
    project_id                                = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies : (
        (policy.feed_id != null) != (policy.feed_key != null)
      )
    ])
    error_message = "feed_retention_policies must set exactly one of feed_id or feed_key."
  }

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
      for policy in var.feed_retention_policies : (
        policy.feed_id == null || length(trimspace(policy.feed_id)) > 0
      )
    ])
    error_message = "feed_retention_policies.feed_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies : (
        policy.feed_key == null || length(trimspace(policy.feed_key)) > 0
      )
    ])
    error_message = "feed_retention_policies.feed_key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies : (
        policy.feed_key == null || contains(keys(var.feeds), policy.feed_key)
      )
    ])
    error_message = "feed_retention_policies.feed_key must reference a key in feeds."
  }

  validation {
    condition = alltrue([
      for policy in var.feed_retention_policies : (
        policy.project_id == null || length(trimspace(policy.project_id)) > 0
      )
    ])
    error_message = "feed_retention_policies.project_id must be a non-empty string when provided."
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
      coalesce(policy.key, policy.feed_key, policy.feed_id)
    ])) == length(var.feed_retention_policies)
    error_message = "feed_retention_policies must have unique keys (key, feed_key, or feed_id)."
  }
}
