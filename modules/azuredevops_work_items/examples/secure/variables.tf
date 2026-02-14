variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "title" {
  description = "Title for the secure work item example."
  type        = string
  default     = "Secure Example Work Item"
}

variable "area_path" {
  description = "Area path to assign to the work item."
  type        = string
  default     = "\\"
}

variable "iteration_path" {
  description = "Iteration path to assign to the work item."
  type        = string
  default     = "\\"
}

variable "description" {
  description = "Description text for the work item."
  type        = string
  default     = "Work item managed by Terraform secure example."
}
