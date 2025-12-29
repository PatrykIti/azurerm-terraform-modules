variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "random_suffix" {
  description = "Random suffix to ensure unique team names."
  type        = string
  default     = "local"
}
