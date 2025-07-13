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

# Virtual Network Peerings
variable "peerings" {
  description = "List of Virtual Network peerings to create."
  type = list(object({
    name                         = string
    remote_virtual_network_id    = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
    triggers                     = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for peering in var.peerings : !(peering.allow_gateway_transit && peering.use_remote_gateways)
    ])
    error_message = "allow_gateway_transit and use_remote_gateways cannot both be true for the same peering."
  }
}

# Network Watcher Flow Log
variable "flow_log" {
  description = "Network Watcher Flow Log configuration."
  type = object({
    network_watcher_name                = string
    network_watcher_resource_group_name = string
    network_security_group_id           = string
    storage_account_id                  = string
    enabled                             = optional(bool, true)
    version                             = optional(number, 2)
    retention_policy = optional(object({
      enabled = bool
      days    = number
    }))
    traffic_analytics = optional(object({
      enabled               = bool
      workspace_id          = string
      workspace_region      = string
      workspace_resource_id = string
      interval_in_minutes   = optional(number, 10)
    }))
  })
  default = null


}

# Private DNS Zone Links
variable "private_dns_zone_links" {
  description = "List of Private DNS Zone Virtual Network Links to create."
  type = list(object({
    name                  = string
    resource_group_name   = string
    private_dns_zone_name = string
    registration_enabled  = optional(bool, false)
    tags                  = optional(map(string), {})
  }))
  default = []
}

# Diagnostic Settings
variable "diagnostic_settings" {
  description = "Diagnostic settings configuration for monitoring and logging."
  type = object({
    enabled                    = optional(bool, false)
    log_analytics_workspace_id = optional(string)
    storage_account_id         = optional(string)
    eventhub_auth_rule_id      = optional(string)
    logs = optional(object({
      vm_protection_alerts = optional(bool, true)
    }), {})
    metrics = optional(object({
      all_metrics = optional(bool, true)
    }), {})
  })
  default = {
    enabled = false
    logs = {
      vm_protection_alerts = true
    }
    metrics = {
      all_metrics = true
    }
  }
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the Virtual Network and associated resources."
  type        = map(string)
  default     = {}
}