variable "subscription_id" {
  description = "Azure subscription ID for testing"
  type        = string
}

variable "subnet_suffix" {
  description = "Random suffix for subnet name"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "northeurope"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}