variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repo_name_prefix" {
  description = "Prefix for the repository name."
  type        = string
  default     = "ado-repo-secure"
}

variable "reviewer_count" {
  description = "Minimum number of reviewers required."
  type        = number
  default     = 2
}

variable "status_check_name" {
  description = "Status check name to enforce."
  type        = string
}

variable "status_check_genre" {
  description = "Optional status check genre."
  type        = string
  default     = null
}
