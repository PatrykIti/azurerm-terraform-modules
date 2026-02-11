variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repository_id" {
  description = "Repository ID for the code wiki."
  type        = string
}

variable "repository_version" {
  description = "Repository branch or tag for the code wiki."
  type        = string
  default     = "main"
}
