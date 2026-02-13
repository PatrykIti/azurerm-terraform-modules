# -----------------------------------------------------------------------------
# Group Entitlement
# -----------------------------------------------------------------------------

variable "group_entitlement" {
  description = "Group entitlement configuration. Provide either display_name or origin+origin_id."
  type = object({
    key                  = optional(string)
    display_name         = optional(string)
    origin_id            = optional(string)
    origin               = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  })

  validation {
    condition     = var.group_entitlement.key == null || trimspace(var.group_entitlement.key) != ""
    error_message = "group_entitlement.key must be a non-empty string when set."
  }

  validation {
    condition     = var.group_entitlement.display_name == null || trimspace(var.group_entitlement.display_name) != ""
    error_message = "group_entitlement.display_name must be a non-empty string when set."
  }

  validation {
    condition     = var.group_entitlement.origin == null || trimspace(var.group_entitlement.origin) != ""
    error_message = "group_entitlement.origin must be a non-empty string when set."
  }

  validation {
    condition     = var.group_entitlement.origin_id == null || trimspace(var.group_entitlement.origin_id) != ""
    error_message = "group_entitlement.origin_id must be a non-empty string when set."
  }

  validation {
    condition = (
      (var.group_entitlement.display_name != null && var.group_entitlement.origin_id == null && var.group_entitlement.origin == null) ||
      (var.group_entitlement.display_name == null && var.group_entitlement.origin_id != null && var.group_entitlement.origin != null)
    )
    error_message = "group_entitlement must set either display_name or origin+origin_id (and not both)."
  }

  validation {
    condition = contains([
      "advanced",
      "earlyAdopter",
      "express",
      "none",
      "professional",
      "stakeholder",
    ], var.group_entitlement.account_license_type)
    error_message = "group_entitlement.account_license_type must be one of: advanced, earlyAdopter, express, none, professional, stakeholder."
  }

  validation {
    condition = contains([
      "account",
      "auto",
      "msdn",
      "none",
      "profile",
      "trial"
    ], var.group_entitlement.licensing_source)
    error_message = "group_entitlement.licensing_source must be one of: account, auto, msdn, none, profile, trial."
  }
}
