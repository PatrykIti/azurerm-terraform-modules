variable "user_principal_name" {
  description = "User principal name for entitlement assignment."
  type        = string
  default     = null

  validation {
    condition     = var.user_principal_name == null || trimspace(var.user_principal_name) != ""
    error_message = "user_principal_name must be a non-empty string when set."
  }
}

variable "user_origin_id" {
  description = "Origin ID for entitlement assignment."
  type        = string
  default     = null

  validation {
    condition     = var.user_origin_id == null || trimspace(var.user_origin_id) != ""
    error_message = "user_origin_id must be a non-empty string when set."
  }

  validation {
    condition = (
      (var.user_principal_name != null && trimspace(var.user_principal_name) != "") ||
      (var.user_origin_id != null && trimspace(var.user_origin_id) != "")
    )
    error_message = "Either user_principal_name or user_origin_id must be set."
  }
}

variable "user_origin" {
  description = "Origin for entitlement assignment."
  type        = string
  default     = "aad"
}
