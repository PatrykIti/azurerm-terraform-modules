variable "resource_id" {
  description = "Target resource ID for the role assignment."
  type        = string
}

variable "role_name" {
  description = "Role name to assign."
  type        = string
  default     = "Reader"
}

variable "identity_id" {
  description = "Identity ID for the role assignment."
  type        = string
}
