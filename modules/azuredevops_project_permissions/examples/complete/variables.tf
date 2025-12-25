variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "group_name_prefix" {
  description = "Prefix for variable group names."
  type        = string
  default     = "app-vars"
}

variable "secret_group_name_prefix" {
  description = "Prefix for secret variable group names."
  type        = string
  default     = "secret-vars"
}

variable "principal_descriptor" {
  description = "Principal descriptor for variable group permissions."
  type        = string
}

variable "library_principal_descriptor" {
  description = "Principal descriptor for library permissions."
  type        = string
}
