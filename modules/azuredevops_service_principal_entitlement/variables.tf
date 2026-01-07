# -----------------------------------------------------------------------------
# Service Principal Entitlements
# -----------------------------------------------------------------------------

variable "service_principal_entitlements" {
  description = "List of service principal entitlements to manage."
  type = list(object({
    key                  = optional(string)
    origin_id            = string
    origin               = optional(string, "aad")
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements :
      entitlement.key == null || trimspace(entitlement.key) != ""
    ])
    error_message = "service_principal_entitlements.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements :
      trimspace(entitlement.origin_id) != ""
    ])
    error_message = "service_principal_entitlements.origin_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements : (
        entitlement.origin == null || entitlement.origin == "aad"
      )
    ])
    error_message = "service_principal_entitlements.origin must be \"aad\" when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements : contains([
        "advanced",
        "earlyAdopter",
        "express",
        "none",
        "professional",
        "stakeholder",
        "basic"
      ], entitlement.account_license_type)
    ])
    error_message = "service_principal_entitlements.account_license_type must be a valid Azure DevOps license type."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements : contains([
        "account",
        "auto",
        "msdn",
        "none",
        "profile",
        "trial"
      ], entitlement.licensing_source)
    ])
    error_message = "service_principal_entitlements.licensing_source must be a valid licensing source."
  }

  validation {
    condition = length(distinct([
      for entitlement in var.service_principal_entitlements : coalesce(entitlement.key, entitlement.origin_id)
    ])) == length(var.service_principal_entitlements)
    error_message = "service_principal_entitlements keys must be unique (derived from key or origin_id)."
  }
}
