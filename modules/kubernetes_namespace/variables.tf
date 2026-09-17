variable "name" {
  description = "Namespace name. Must be a valid DNS-1123 label."
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
  description = "Labels to apply to the namespace."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the namespace."
  type        = map(string)
  default     = {}
}

variable "wait_for_default_service_account" {
  description = "If true, Terraform waits for the default service account to be created in the namespace."
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Optional timeouts for the namespace resource."
  type = object({
    delete = optional(string)
  })
  default = {}
}
