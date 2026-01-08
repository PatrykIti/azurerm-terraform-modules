variable "user_origin_id" {
  description = "Origin ID for entitlement assignment."
  type        = string
}

variable "user_origin" {
  description = "Origin for entitlement assignment."
  type        = string
  default     = "aad"
}
