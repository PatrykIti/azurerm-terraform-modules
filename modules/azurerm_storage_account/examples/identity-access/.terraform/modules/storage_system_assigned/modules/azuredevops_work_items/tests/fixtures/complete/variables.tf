variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "work_item_title_prefix" {
  description = "Prefix for work item titles."
  type        = string
  default     = "ado-work-item"
}
