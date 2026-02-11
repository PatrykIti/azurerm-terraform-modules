variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name for OpenAI."
  type        = string
  default     = "privatelink.openai.azure.com"
}

variable "private_endpoint_subresource" {
  description = "Private endpoint subresource name for Cognitive Accounts."
  type        = string
  default     = "account"
}

variable "tags" {
  description = "Tags to apply to the Cognitive Account."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Secure"
  }
}
