variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}

variable "bgp_route_propagation_enabled" {
  description = "Boolean flag which controls propagation of routes learned by BGP"
  type        = bool
  default     = false
}

variable "additional_routes" {
  description = "Additional routes to add to the route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}
