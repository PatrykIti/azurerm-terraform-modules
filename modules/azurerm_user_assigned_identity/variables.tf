# Core User Assigned Identity Variables
variable "name" {
  description = "The name of the User Assigned Identity. Must be 3-128 characters, start with a letter or number, and contain only letters, numbers, hyphens, or underscores."
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 128
    error_message = "The name must be between 3 and 128 characters long."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-_]*$", var.name))
    error_message = "The name must start with a letter or number and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the User Assigned Identity."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "The resource_group_name must not be empty."
  }
}

variable "location" {
  description = "The Azure Region where the User Assigned Identity should exist."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "The location must not be empty."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the User Assigned Identity."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Optional timeouts for User Assigned Identity operations."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}

variable "federated_identity_credentials" {
  description = <<-EOT
    List of federated identity credentials to associate with this User Assigned Identity.

    Each entry must include:
    - name: 3-120 characters, start with a letter or number, contain only letters, numbers, hyphens, or underscores.
    - issuer: HTTPS issuer URL.
    - subject: non-empty subject claim.
    - audience: non-empty list of audience values.
  EOT

  type = list(object({
    name     = string
    issuer   = string
    subject  = string
    audience = list(string)
  }))
  default = []

  validation {
    condition     = length(var.federated_identity_credentials) == length(distinct([for fic in var.federated_identity_credentials : fic.name]))
    error_message = "Federated identity credential names must be unique."
  }

  validation {
    condition = alltrue([
      for fic in var.federated_identity_credentials :
      length(fic.name) >= 3 && length(fic.name) <= 120
    ])
    error_message = "Federated identity credential names must be between 3 and 120 characters long."
  }

  validation {
    condition = alltrue([
      for fic in var.federated_identity_credentials :
      can(regex("^[A-Za-z0-9][A-Za-z0-9-_]*$", fic.name))
    ])
    error_message = "Federated identity credential names must start with a letter or number and contain only letters, numbers, hyphens, or underscores."
  }

  validation {
    condition = alltrue([
      for fic in var.federated_identity_credentials :
      can(regex("^https://", fic.issuer)) && length(trimspace(fic.issuer)) > 8
    ])
    error_message = "Federated identity credential issuer must be a valid HTTPS URL."
  }

  validation {
    condition = alltrue([
      for fic in var.federated_identity_credentials :
      length(trimspace(fic.subject)) > 0
    ])
    error_message = "Federated identity credential subject must not be empty."
  }

  validation {
    condition = alltrue([
      for fic in var.federated_identity_credentials :
      length(fic.audience) > 0 && alltrue([for aud in fic.audience : length(trimspace(aud)) > 0])
    ])
    error_message = "Federated identity credential audience must be a non-empty list with no empty values."
  }
}

variable "federated_identity_credential_timeouts" {
  description = "Optional timeouts applied to all federated identity credential operations."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}
