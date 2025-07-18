# Core Route Table Variables
variable "name" {
  description = "The name of the Route Table. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition = alltrue([
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name)),
      length(var.name) >= 1,
      length(var.name) <= 80
    ])
    error_message = "Route Table name must be 1-80 characters long, start with alphanumeric, and contain only letters, numbers, hyphens, periods, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Route Table."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Route Table should exist."
  type        = string
}

# BGP Route Propagation
variable "bgp_route_propagation_enabled" {
  description = "Enable BGP route propagation on the Route Table. Defaults to true."
  type        = bool
  default     = true
}

# Custom Routes
variable "routes" {
  description = "List of custom routes to create in the route table."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.routes :
      contains(["VirtualAppliance", "VirtualNetworkGateway", "VnetLocal", "Internet", "None"], route.next_hop_type)
    ])
    error_message = "The next_hop_type must be one of: VirtualAppliance, VirtualNetworkGateway, VnetLocal, Internet, None."
  }

  validation {
    condition = alltrue([
      for route in var.routes :
      (route.next_hop_type == "VirtualAppliance" && route.next_hop_in_ip_address != null) ||
      (route.next_hop_type != "VirtualAppliance" && route.next_hop_in_ip_address == null)
    ])
    error_message = "The next_hop_in_ip_address must be provided when next_hop_type is 'VirtualAppliance' and must be null otherwise."
  }
}

# Subnet Associations
variable "subnet_ids_to_associate" {
  description = "A list of subnet IDs to associate with this route table."
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}