variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "wiki_name_prefix" {
  description = "Prefix for wiki names."
  type        = string
  default     = "ado-wiki"
}
