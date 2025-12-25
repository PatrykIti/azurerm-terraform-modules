variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "parent_process_type_id" {
  description = "Parent process type ID for custom processes."
  type        = string
  default     = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
}

variable "principal_descriptor" {
  description = "Principal descriptor for query permissions."
  type        = string
}
