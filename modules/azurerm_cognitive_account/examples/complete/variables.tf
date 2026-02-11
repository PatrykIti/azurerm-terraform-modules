variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-cognitive-account-complete"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "account_name" {
  description = "Cognitive Account name for the example."
  type        = string
  default     = "cogopenai-complete"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain name for the Cognitive Account."
  type        = string
  default     = "cogopenai-complete"
}

variable "virtual_network_name" {
  description = "Virtual network name for the example."
  type        = string
  default     = "vnet-cog-complete"
}

variable "subnet_name" {
  description = "Subnet name for the example."
  type        = string
  default     = "snet-cog-complete"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name for the example."
  type        = string
  default     = "law-cog-complete"
}

variable "user_assigned_identity_name" {
  description = "User assigned identity name for the example."
  type        = string
  default     = "uai-cog-complete"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges for network ACLs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Production"
    Example     = "Complete"
  }
}
