variable "name" {
  description = "RoleBinding name. Must be a valid DNS-1123 label."
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
  description = "Namespace where the RoleBinding is created."
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
  description = "Labels to apply to the RoleBinding."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the RoleBinding."
  type        = map(string)
  default     = {}
}

variable "role_ref" {
  description = "Reference to the Role or ClusterRole bound by this RoleBinding."
  type = object({
    api_group = optional(string, "rbac.authorization.k8s.io")
    kind      = optional(string, "Role")
    name      = string
  })

  validation {
    condition     = contains(["Role", "ClusterRole"], var.role_ref.kind)
    error_message = "role_ref.kind must be either Role or ClusterRole."
  }
}

variable "subjects" {
  description = "Subjects bound by the RoleBinding."
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
