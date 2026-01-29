variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "cluster_location" {
  description = "Azure region for the Log Analytics cluster."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-law-cmk-example"
}

variable "workspace_name" {
  description = "Log Analytics Workspace name."
  type        = string
  default     = "law-cmk-example"
}

variable "cluster_name" {
  description = "Log Analytics cluster name."
  type        = string
  default     = "law-cmk-cluster"
}

variable "key_vault_name" {
  description = "Key Vault name for CMK."
  type        = string
  default     = "kvlawcmkexample"
}
