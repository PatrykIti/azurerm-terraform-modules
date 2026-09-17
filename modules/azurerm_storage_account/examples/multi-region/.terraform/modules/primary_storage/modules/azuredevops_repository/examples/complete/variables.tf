variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "principal_descriptor" {
  description = "Descriptor of the group used for git permissions."
  type        = string
}

variable "build_definition_id" {
  description = "Build definition ID for build validation policy."
  type        = string
}

variable "reviewer_count" {
  description = "Minimum number of reviewers required."
  type        = number
  default     = 2
}

variable "author_email_patterns" {
  description = "Allowed author email patterns for commits."
  type        = list(string)
  default     = ["*@example.com"]
}
