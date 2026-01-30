# -----------------------------------------------------------------------------
# User Entitlements
# -----------------------------------------------------------------------------

variable "user_entitlement" {
  description = "User entitlement configuration. Provide either principal_name or origin+origin_id."
  type = object({
    key                  = optional(string)
    principal_name       = optional(string)
    origin_id            = optional(string)
    origin               = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  })

  validation {
    condition     = var.user_entitlement.key == null || trimspace(var.user_entitlement.key) != ""
    error_message = "user_entitlement.key must be a non-empty string when set."
  }

  validation {
    condition     = var.user_entitlement.principal_name == null || trimspace(var.user_entitlement.principal_name) != ""
    error_message = "user_entitlement.principal_name must be a non-empty string when set."
  }

  validation {
    condition     = var.user_entitlement.origin == null || trimspace(var.user_entitlement.origin) != ""
    error_message = "user_entitlement.origin must be a non-empty string when set."
  }

  validation {
    condition     = var.user_entitlement.origin_id == null || trimspace(var.user_entitlement.origin_id) != ""
    error_message = "user_entitlement.origin_id must be a non-empty string when set."
  }

  validation {
    condition = (
      (var.user_entitlement.principal_name != null && var.user_entitlement.origin_id == null && var.user_entitlement.origin == null) ||
      (var.user_entitlement.principal_name == null && var.user_entitlement.origin_id != null && var.user_entitlement.origin != null)
    )
    error_message = "user_entitlement must set either principal_name or origin+origin_id (and not both)."
  }

  validation {
    condition = contains([
      "advanced",
      "earlyAdopter",
      "express",
      "none",
      "professional",
      "stakeholder",
      "basic"
    ], var.user_entitlement.account_license_type)
    error_message = "user_entitlement.account_license_type must be one of: advanced, earlyAdopter, express, none, professional, stakeholder, basic."
  }

  validation {
    condition = contains([
      "account",
      "auto",
      "msdn",
      "none",
      "profile",
      "trial"
    ], var.user_entitlement.licensing_source)
    error_message = "user_entitlement.licensing_source must be one of: account, auto, msdn, none, profile, trial."
  }
}
