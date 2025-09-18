variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}

variable "name" {
  description = "The name of the Route Table"
  type        = string
  default     = "" # Empty default, will be set from test
}

variable "routes" {
  description = "List of route configurations"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}