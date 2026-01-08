variable "resource_id" {
  description = "Target resource ID for the role assignment."
  type        = string
}

variable "scope" {
  description = "Security role scope ID."
  type        = string
}

variable "role_name" {
  description = "Role name to assign. Allowed values: Administrator, Reader, User; for scope distributedtask.library, Creator is also allowed."
  type        = string
  default     = "Reader"
}

variable "identity_id" {
  description = "Identity ID for the role assignment."
  type        = string
}
