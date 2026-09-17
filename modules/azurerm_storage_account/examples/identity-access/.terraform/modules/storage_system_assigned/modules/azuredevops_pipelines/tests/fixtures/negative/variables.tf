variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
  default     = "neg"
}
