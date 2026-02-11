variable "name" {
  description = "The name of the Private Endpoint. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_.-]{0,78}[A-Za-z0-9]$", var.name))
    error_message = "The name must be 1-80 characters, start and end with an alphanumeric character, and contain only letters, numbers, periods, underscores, or hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Private Endpoint. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "The Azure region where the Private Endpoint should exist. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "subnet_id" {
  description = "The ID of the subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", trimspace(var.subnet_id)))
    error_message = "subnet_id must be a valid Azure subnet resource ID."
  }
}

variable "custom_network_interface_name" {
  description = "The custom name of the network interface attached to the private endpoint. Changing this forces a new resource to be created."
  type        = string
  default     = null

  validation {
    condition     = var.custom_network_interface_name == null || can(regex("^[A-Za-z0-9][A-Za-z0-9_.-]{0,78}[A-Za-z0-9]$", trimspace(var.custom_network_interface_name)))
    error_message = "custom_network_interface_name must be 1-80 characters, start and end with an alphanumeric character, and contain only letters, numbers, periods, underscores, or hyphens."
  }
}

variable "private_service_connections" {
  description = <<-EOT
    The private service connection configuration for the Private Endpoint.

    Exactly one connection is supported by the provider schema.
  EOT

  type = list(object({
    name                              = string
    is_manual_connection              = bool
    private_connection_resource_id    = optional(string)
    private_connection_resource_alias = optional(string)
    subresource_names                 = optional(list(string))
    request_message                   = optional(string)
  }))

  validation {
    condition     = length(var.private_service_connections) == 1
    error_message = "Exactly one private_service_connection block must be provided."
  }

  validation {
    condition     = length(var.private_service_connections) == length(distinct([for conn in var.private_service_connections : conn.name]))
    error_message = "private_service_connections names must be unique."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      length(trimspace(conn.name)) > 0
    ])
    error_message = "private_service_connections.name must not be empty or whitespace."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      (try(conn.private_connection_resource_id, null) != null) != (try(conn.private_connection_resource_alias, null) != null)
    ])
    error_message = "Each private_service_connection must set exactly one of private_connection_resource_id or private_connection_resource_alias."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      try(conn.private_connection_resource_id, null) == null || length(trimspace(conn.private_connection_resource_id)) > 0
    ])
    error_message = "private_connection_resource_id must not be empty or whitespace when provided."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      try(conn.private_connection_resource_alias, null) == null || length(trimspace(conn.private_connection_resource_alias)) > 0
    ])
    error_message = "private_connection_resource_alias must not be empty or whitespace when provided."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      conn.is_manual_connection == false || (try(conn.request_message, null) != null && length(trimspace(conn.request_message)) > 0)
    ])
    error_message = "request_message is required when is_manual_connection is true."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      try(conn.request_message, null) == null || length(conn.request_message) <= 140
    ])
    error_message = "request_message must be 140 characters or fewer when provided."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      try(conn.subresource_names, null) == null || length(conn.subresource_names) > 0
    ])
    error_message = "subresource_names must contain at least one value when provided."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      try(conn.subresource_names, null) == null || alltrue([
        for subresource_name in conn.subresource_names :
        length(trimspace(subresource_name)) > 0
      ])
    ])
    error_message = "Each subresource_names value must not be empty or whitespace."
  }

  validation {
    condition = alltrue([
      for conn in var.private_service_connections :
      try(conn.subresource_names, null) == null || length(distinct([for subresource_name in conn.subresource_names : lower(trimspace(subresource_name))])) == length(conn.subresource_names)
    ])
    error_message = "subresource_names values must be unique when provided."
  }
}

variable "ip_configurations" {
  description = "Optional static IP configuration blocks for the Private Endpoint."
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = optional(string)
    member_name        = optional(string)
  }))
  default = []

  validation {
    condition     = length(var.ip_configurations) == length(distinct([for cfg in var.ip_configurations : cfg.name]))
    error_message = "ip_configurations names must be unique."
  }

  validation {
    condition = alltrue([
      for cfg in var.ip_configurations :
      length(trimspace(cfg.name)) > 0
    ])
    error_message = "ip_configurations.name must not be empty or whitespace."
  }

  validation {
    condition = alltrue([
      for cfg in var.ip_configurations :
      length(trimspace(cfg.private_ip_address)) > 0 && can(cidrhost(format("%s/%s", trimspace(cfg.private_ip_address), can(regex(":", trimspace(cfg.private_ip_address))) ? "128" : "32"), 0))
    ])
    error_message = "ip_configurations.private_ip_address must be a valid IPv4 or IPv6 address."
  }

  validation {
    condition = alltrue([
      for cfg in var.ip_configurations :
      try(cfg.subresource_name, null) == null || length(trimspace(cfg.subresource_name)) > 0
    ])
    error_message = "ip_configurations.subresource_name must not be empty or whitespace when provided."
  }

  validation {
    condition = alltrue([
      for cfg in var.ip_configurations :
      try(cfg.member_name, null) == null || length(trimspace(cfg.member_name)) > 0
    ])
    error_message = "ip_configurations.member_name must not be empty or whitespace when provided."
  }
}

variable "private_dns_zone_groups" {
  description = <<-EOT
    Optional private DNS zone group configuration for the Private Endpoint.

    The provider schema allows at most one group.
  EOT

  type = list(object({
    name                 = string
    private_dns_zone_ids = list(string)
  }))
  default = []

  validation {
    condition     = length(var.private_dns_zone_groups) <= 1
    error_message = "At most one private_dns_zone_group is supported by the provider."
  }

  validation {
    condition     = length(var.private_dns_zone_groups) == length(distinct([for group in var.private_dns_zone_groups : group.name]))
    error_message = "private_dns_zone_groups names must be unique."
  }

  validation {
    condition = alltrue([
      for group in var.private_dns_zone_groups :
      length(trimspace(group.name)) > 0
    ])
    error_message = "private_dns_zone_groups.name must not be empty or whitespace."
  }

  validation {
    condition = alltrue([
      for group in var.private_dns_zone_groups : length(group.private_dns_zone_ids) > 0
    ])
    error_message = "private_dns_zone_groups.private_dns_zone_ids must contain at least one Private DNS Zone ID."
  }

  validation {
    condition = alltrue([
      for group in var.private_dns_zone_groups : alltrue([
        for zone_id in group.private_dns_zone_ids :
        length(trimspace(zone_id)) > 0 && can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/privateDnsZones/[^/]+$", trimspace(zone_id)))
      ])
    ])
    error_message = "Each private_dns_zone_id must be a valid Azure Private DNS Zone resource ID."
  }

  validation {
    condition = alltrue([
      for group in var.private_dns_zone_groups :
      length(distinct([for zone_id in group.private_dns_zone_ids : lower(trimspace(zone_id))])) == length(group.private_dns_zone_ids)
    ])
    error_message = "private_dns_zone_groups.private_dns_zone_ids must contain unique values."
  }
}

variable "timeouts" {
  description = "Optional timeouts for Private Endpoint operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
