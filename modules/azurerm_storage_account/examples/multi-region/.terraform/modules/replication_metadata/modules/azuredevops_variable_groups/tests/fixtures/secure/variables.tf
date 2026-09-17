variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "group_name_prefix" {
  description = "Prefix for variable group names."
  type        = string
  default     = "ado-vg-secure"
}
