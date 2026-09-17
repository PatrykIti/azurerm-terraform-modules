variable "user_principal_name" {
  description = "User principal name for negative fixture validation."
  type        = string
  default     = "invalid-user@example.com"
}

variable "user_origin_id" {
  description = "Origin ID for negative fixture validation."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "user_origin" {
  description = "Origin for negative fixture validation."
  type        = string
  default     = "aad"
}
