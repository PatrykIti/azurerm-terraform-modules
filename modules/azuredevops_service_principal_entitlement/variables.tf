# -----------------------------------------------------------------------------
# Service Principal Entitlement
# -----------------------------------------------------------------------------

variable "origin_id" {
  description = "Service principal object ID used to create the entitlement."
  type        = string

  validation {
    condition     = trimspace(var.origin_id) != ""
    error_message = "origin_id must be a non-empty string."
  }
}

variable "origin" {
  description = "Origin for the service principal. Only \"aad\" is supported."
  type        = string
  default     = "aad"

  validation {
    condition     = var.origin == "aad"
    error_message = "origin must be \"aad\"."
  }
}

variable "account_license_type" {
  description = "License type to assign to the service principal."
  type        = string
  default     = "express"

  validation {
    condition = contains([
      "advanced",
      "earlyAdopter",
      "express",
      "none",
      "professional",
      "stakeholder",
      "basic"
    ], var.account_license_type)
    error_message = "account_license_type must be a valid Azure DevOps license type."
  }
}

variable "licensing_source" {
  description = "Licensing source for the service principal entitlement."
  type        = string
  default     = "account"

  validation {
    condition = contains([
      "account",
      "auto",
      "msdn",
      "none",
      "profile",
      "trial"
    ], var.licensing_source)
    error_message = "licensing_source must be a valid licensing source."
  }
}
