# Core Virtual Network Variables
variable "name" {
  description = "The name of the Virtual Network. Must be unique within the resource group."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "Virtual Network name must be 2-80 characters long, start and end with alphanumeric characters, and can contain hyphens, periods, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Virtual Network."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Virtual Network should exist."
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the Virtual Network. You can supply more than one address space."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be provided."
  }
}

# DNS Configuration
variable "dns_servers" {
  description = "List of IP addresses of DNS servers for the Virtual Network. If not specified, Azure-provided DNS is used."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for dns in var.dns_servers : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", dns))
    ])
    error_message = "All DNS servers must be valid IPv4 addresses."
  }
}

# Network Flow Configuration
variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes."
  type        = number
  default     = 4

  validation {
    condition     = var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30
    error_message = "Flow timeout must be between 4 and 30 minutes."
  }
}

# BGP Community
variable "bgp_community" {
  description = "The BGP community attribute in format <as-number>:<community-value>. Only applicable if the Virtual Network is connected to ExpressRoute."
  type        = string
  default     = null

  validation {
    condition     = var.bgp_community == null || can(regex("^[0-9]+:[0-9]+$", var.bgp_community))
    error_message = "BGP community must be in format <as-number>:<community-value> (e.g., 12076:20000)."
  }
}

# Edge Zone
variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network should exist."
  type        = string
  default     = null
}

# DDoS Protection Plan
variable "ddos_protection_plan" {
  description = "DDoS protection plan configuration for the Virtual Network."
  type = object({
    id     = string
    enable = bool
  })
  default = null
}

# Encryption Configuration
variable "encryption" {
  description = "Encryption configuration for the Virtual Network."
  type = object({
    enforcement = string
  })
  default = null


}





# Tags
variable "tags" {
  description = "A mapping of tags to assign to the Virtual Network and associated resources."
  type        = map(string)
  default     = {}
}