variable "group_name_prefix" {
  description = "Prefix for Azure DevOps group names."
  type        = string
  default     = "ado-identity-complete"
}

variable "user_principal_name" {
  description = "Optional user principal name for entitlement assignment."
  type        = string
  default     = ""
}

variable "aad_group_display_name" {
  description = "Optional Azure AD group display name for group entitlements."
  type        = string
  default     = ""
}

variable "service_principal_origin_id" {
  description = "Optional Azure AD service principal object ID for entitlement."
  type        = string
  default     = ""
}

variable "security_role_assignments" {
  description = "Optional security role assignments to apply."
  type = list(object({
    scope              = string
    resource_id        = string
    role_name          = string
    identity_id        = optional(string)
    identity_group_key = optional(string)
  }))
  default = []
}
