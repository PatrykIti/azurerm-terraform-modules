variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "project_group_name" {
  description = "Project-scoped group name to grant permissions."
  type        = string
  default     = "Readers"
}
