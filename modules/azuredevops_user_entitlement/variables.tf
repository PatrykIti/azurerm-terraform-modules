# -----------------------------------------------------------------------------
# User Entitlements
# -----------------------------------------------------------------------------

variable "user_entitlements" {
  description = "List of user entitlements to manage."
  type = list(object({
    key                  = optional(string)
    principal_name       = optional(string)
    origin_id            = optional(string)
    origin               = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.key == null || trimspace(entitlement.key) != ""
    ])
    error_message = "user_entitlements.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.principal_name == null || trimspace(entitlement.principal_name) != ""
    ])
    error_message = "user_entitlements.principal_name must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.origin == null || trimspace(entitlement.origin) != ""
    ])
    error_message = "user_entitlements.origin must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.origin_id == null || trimspace(entitlement.origin_id) != ""
    ])
    error_message = "user_entitlements.origin_id must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements : (
        (entitlement.principal_name != null && entitlement.origin_id == null && entitlement.origin == null) ||
        (entitlement.principal_name == null && entitlement.origin_id != null && entitlement.origin != null)
      )
    ])
    error_message = "Each user_entitlement must set principal_name or origin+origin_id, but not both."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements : contains([
        "advanced",
        "earlyAdopter",
        "express",
        "none",
        "professional",
        "stakeholder",
        "basic"
      ], entitlement.account_license_type)
    ])
    error_message = "user_entitlements.account_license_type must be a valid Azure DevOps license type."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements : contains([
        "account",
        "auto",
        "msdn",
        "none",
        "profile",
        "trial"
      ], entitlement.licensing_source)
    ])
    error_message = "user_entitlements.licensing_source must be a valid licensing source."
  }

  validation {
    condition = length(distinct([
      for entitlement in var.user_entitlements : coalesce(entitlement.key, entitlement.principal_name, entitlement.origin_id)
    ])) == length(var.user_entitlements)
    error_message = "user_entitlements keys must be unique (derived from key, principal_name, or origin_id)."
  }
}
