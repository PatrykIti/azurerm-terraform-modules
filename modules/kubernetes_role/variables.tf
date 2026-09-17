variable "name" {
  description = "Role name. Must be a valid DNS-1123 label."
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

variable "namespace" {
  description = "Namespace where the Role is created."
  type        = string

  validation {
    condition     = length(var.namespace) > 0 && length(var.namespace) <= 253
    error_message = "namespace must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "namespace must be a valid DNS-1123 label (lowercase letters, numbers, hyphens)."
  }
}

variable "labels" {
  description = "Labels to apply to the Role."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the Role."
  type        = map(string)
  default     = {}
}

variable "rules" {
  description = "Namespace-scoped RBAC rules for the Role."
  type = list(object({
    api_groups     = set(string)
    resources      = set(string)
    verbs          = set(string)
    resource_names = optional(set(string))
  }))

  validation {
    condition     = length(var.rules) > 0
    error_message = "rules must contain at least one item."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      length(rule.api_groups) > 0 &&
      length(rule.resources) > 0 &&
      length(rule.verbs) > 0
    ])
    error_message = "Each rules entry must define at least one api_group, resource, and verb."
  }
}
