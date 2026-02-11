variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-cognitive-account-private-endpoint"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "account_name" {
  description = "Cognitive Account name for the example."
  type        = string
  default     = "cogopenai-pe"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain name for the Cognitive Account."
  type        = string
  default     = "cogopenai-pe"
}

variable "virtual_network_name" {
  description = "Virtual network name for the example."
  type        = string
  default     = "vnet-cog-pe"
}

variable "subnet_name" {
  description = "Subnet name for the private endpoint."
  type        = string
  default     = "snet-pe-cog"
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name for OpenAI."
  type        = string
  default     = "privatelink.openai.azure.com"
}

variable "private_dns_zone_link_name" {
  description = "Private DNS zone link name."
  type        = string
  default     = "pdns-cog-pe-link"
}

variable "private_endpoint_name" {
  description = "Private endpoint name."
  type        = string
  default     = "pe-cog"
}

variable "private_endpoint_subresource" {
  description = "Private endpoint subresource name for Cognitive Accounts."
  type        = string
  default     = "account"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Private Endpoint"
  }
}
