variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-linux-vm-complete-example"
}

variable "storage_account_name" {
  description = "Storage account name for boot diagnostics"
  type        = string
  default     = "stlinuxvmcomplete001"
}
