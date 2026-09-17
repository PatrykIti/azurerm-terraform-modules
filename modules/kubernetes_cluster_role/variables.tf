variable "name" {
  description = "ClusterRole name. Must be a valid DNS-1123 label."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 253
    error_message = "name must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be a valid DNS-1123 label (lowercase letters, numbers, hyphens)."
  }
}

variable "labels" {
  description = "Labels to apply to the ClusterRole."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the ClusterRole."
  type        = map(string)
  default     = {}
}

variable "rules" {
  description = "Policy rules for the ClusterRole."
  type = list(object({
    api_groups        = optional(list(string))
    resources         = optional(list(string))
    verbs             = list(string)
    resource_names    = optional(list(string))
    non_resource_urls = optional(list(string))
  }))
  default = []

  validation {
    condition     = length(var.rules) > 0 || var.aggregation_rule != null
    error_message = "Either rules or aggregation_rule must be provided."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      length(rule.verbs) > 0 &&
      (
        (try(length(rule.resources), 0) > 0) ||
        (try(length(rule.non_resource_urls), 0) > 0)
      )
    ])
    error_message = "Each rules entry must define verbs and at least one of resources or non_resource_urls."
  }
}

variable "aggregation_rule" {
  description = "Optional aggregation rule used to compose this ClusterRole from labels on other ClusterRoles."
  type = object({
    cluster_role_selectors = list(object({
      match_labels = optional(map(string))
      match_expressions = optional(list(object({
        key      = optional(string)
        operator = optional(string)
        values   = optional(set(string))
      })), [])
    }))
  })
  default = null
}
