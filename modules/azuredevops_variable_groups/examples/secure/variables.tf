variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "principal_descriptor" {
  description = "Principal descriptor for variable group permissions."
  type        = string
}

variable "secret_token" {
  description = "Secret token value."
  type        = string
  sensitive   = true
}
