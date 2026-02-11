variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-cognitive-account-language"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "account_name" {
  description = "Cognitive Account name for the example."
  type        = string
  default     = "cog-language"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Language Service"
  }
}
