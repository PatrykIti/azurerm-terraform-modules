variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repo_name_prefix" {
  description = "Prefix for the repository name."
  type        = string
  default     = "ado-repo-complete-fixture"
}
