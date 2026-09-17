variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "virtual_network_name" {
  description = "Override for virtual network name (used in tests)"
  type        = string
  default     = ""
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}