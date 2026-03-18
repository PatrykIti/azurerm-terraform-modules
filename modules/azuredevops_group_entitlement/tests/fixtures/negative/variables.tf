variable "group_display_name" {
  description = "Display name of existing group."
  type        = string
  default     = "ADO Platform Team"
}

variable "group_origin" {
  description = "Origin provider for the group."
  type        = string
  default     = "aad"
}

variable "group_origin_id" {
  description = "Origin ID for the group."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}
