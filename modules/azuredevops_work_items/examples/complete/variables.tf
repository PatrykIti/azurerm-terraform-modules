variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "parent_title" {
  description = "Title for the parent work item."
  type        = string
  default     = "Example Parent Work Item"
}

variable "child_title" {
  description = "Title for the child work item."
  type        = string
  default     = "Example Child Work Item"
}
