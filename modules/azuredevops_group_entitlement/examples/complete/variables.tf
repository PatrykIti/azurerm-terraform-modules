variable "group_origin" {
  description = "Group origin provider (for example: aad)."
  type        = string
  default     = "aad"
}

variable "group_origin_id" {
  description = "Origin ID of the Azure AD group."
  type        = string
}

variable "account_license_type" {
  description = "Azure DevOps account license type for the entitlement."
  type        = string
  default     = "basic"
}

variable "licensing_source" {
  description = "Licensing source for the entitlement."
  type        = string
  default     = "account"
}
