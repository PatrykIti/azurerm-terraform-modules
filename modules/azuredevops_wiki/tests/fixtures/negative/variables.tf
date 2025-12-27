variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "wiki_name_prefix" {
  description = "Prefix for wiki names."
  type        = string
  default     = "ado-wiki"
}
