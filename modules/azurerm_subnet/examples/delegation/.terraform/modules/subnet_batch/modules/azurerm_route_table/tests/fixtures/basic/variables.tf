variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}

variable "routes" {
  description = "List of routes to be created in the route table."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}
