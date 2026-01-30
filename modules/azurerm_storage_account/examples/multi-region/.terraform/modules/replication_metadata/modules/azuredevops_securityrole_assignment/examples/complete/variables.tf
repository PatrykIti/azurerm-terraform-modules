variable "project_id" {
  description = "Project ID for role assignments."
  type        = string
}

variable "scope" {
  description = "Security role scope ID."
  type        = string
}

variable "identity_id" {
  description = "Identity ID for the role assignment."
  type        = string
}

variable "role_name" {
  description = "Role name to assign."
  type        = string
  default     = "Reader"
}
