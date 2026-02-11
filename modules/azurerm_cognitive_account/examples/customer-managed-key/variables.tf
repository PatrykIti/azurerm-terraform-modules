variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-cognitive-account-cmk"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "account_name" {
  description = "Cognitive Account name for the example."
  type        = string
  default     = "cogopenai-cmk"
}

variable "user_assigned_identity_name" {
  description = "User assigned identity name for the example."
  type        = string
  default     = "uai-cog-cmk"
}

variable "key_vault_name" {
  description = "Key Vault name for the example."
  type        = string
  default     = "kvcogcmk"
}

variable "key_vault_key_name" {
  description = "Key Vault key name for the example."
  type        = string
  default     = "cog-cmk-key"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Customer Managed Key"
  }
}
