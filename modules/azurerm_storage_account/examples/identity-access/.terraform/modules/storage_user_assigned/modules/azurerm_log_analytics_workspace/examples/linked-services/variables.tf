variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-law-linked-example"
}

variable "workspace_name" {
  description = "Log Analytics Workspace name."
  type        = string
  default     = "law-linked-example"
}

variable "automation_account_name" {
  description = "Automation account name for linked service."
  type        = string
  default     = "aa-law-linked-example"
}
