variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-ehns-basic-example"
}

variable "namespace_name" {
  description = "Event Hub Namespace name for the example."
  type        = string
  default     = "ehnsbasicexample001"
}

variable "sku" {
  description = "Event Hub Namespace SKU."
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Namespace throughput capacity."
  type        = number
  default     = 1
}

variable "auto_inflate_enabled" {
  description = "Whether namespace auto-inflate is enabled."
  type        = bool
  default     = false
}

variable "maximum_throughput_units" {
  description = "Maximum throughput units when auto-inflate is enabled."
  type        = number
  default     = null
}

variable "random_suffix" {
  description = "Random suffix used for test uniqueness."
  type        = string
  default     = ""
}
