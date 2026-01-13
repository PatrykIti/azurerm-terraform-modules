variable "platform_user_principal_name" {
  description = "User principal name for the platform entitlement."
  type        = string
}

variable "automation_user_origin_id" {
  description = "Origin ID for the automation entitlement."
  type        = string
}

variable "automation_user_origin" {
  description = "Origin for the automation entitlement."
  type        = string
  default     = "aad"
}
