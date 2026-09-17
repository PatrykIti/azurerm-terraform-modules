variable "name" {
  description = "ClusterRoleBinding name. Must be a valid DNS-1123 label."
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
  description = "Labels to apply to the ClusterRoleBinding."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the ClusterRoleBinding."
  type        = map(string)
  default     = {}
}

variable "role_ref" {
  description = "Reference to the ClusterRole bound by this ClusterRoleBinding."
  type = object({
    api_group = optional(string, "rbac.authorization.k8s.io")
    kind      = optional(string, "ClusterRole")
    name      = string
  })

  validation {
    condition     = var.role_ref.kind == "ClusterRole"
    error_message = "role_ref.kind must be ClusterRole for a ClusterRoleBinding."
  }
}

variable "subjects" {
  description = "Subjects bound by the ClusterRoleBinding."
  type = list(object({
    kind      = string
    name      = string
    namespace = optional(string)
    api_group = optional(string)
  }))

  validation {
    condition     = length(var.subjects) > 0
    error_message = "subjects must contain at least one item."
  }

  validation {
    condition = alltrue([
      for subject in var.subjects :
      contains(["User", "Group", "ServiceAccount"], subject.kind)
    ])
    error_message = "subjects[*].kind must be one of: User, Group, ServiceAccount."
  }

  validation {
    condition = alltrue([
      for subject in var.subjects :
      subject.kind != "ServiceAccount" || try(subject.namespace, null) != null
    ])
    error_message = "subjects[*].namespace is required when kind is ServiceAccount."
  }
}
