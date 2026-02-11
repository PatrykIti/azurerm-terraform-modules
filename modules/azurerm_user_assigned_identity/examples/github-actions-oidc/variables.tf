variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "github_repository" {
  description = "GitHub repository in the form 'org/repo'."
  type        = string
  default     = "example-org/example-repo"
}

variable "github_ref" {
  description = "Git reference (e.g., refs/heads/main)."
  type        = string
  default     = "refs/heads/main"
}
