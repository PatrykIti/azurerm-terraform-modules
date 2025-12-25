# -----------------------------------------------------------------------------
# Feeds
# -----------------------------------------------------------------------------

variable "feeds" {
  description = "Map of feeds to manage."
  type = map(object({
    name       = optional(string)
    project_id = optional(string)
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
}

# -----------------------------------------------------------------------------
# Feed Permissions
# -----------------------------------------------------------------------------

variable "feed_permissions" {
  description = "List of feed permissions to assign."
  type = list(object({
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
}

# -----------------------------------------------------------------------------
# Feed Retention Policies
# -----------------------------------------------------------------------------

variable "feed_retention_policies" {
  description = "List of feed retention policies to manage."
  type = list(object({
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
}
