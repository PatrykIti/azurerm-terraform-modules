variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-law-basic-example"
}

variable "workspace_name" {
  description = "Log Analytics Workspace name."
  type        = string
  default     = "law-basic-example"
}
