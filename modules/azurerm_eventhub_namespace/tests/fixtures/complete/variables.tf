variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-ehns-complete-example"
}

variable "namespace_name" {
  description = "Event Hub Namespace name for the example."
  type        = string
  default     = "ehnscompleteexample001"
}

variable "sku" {
  description = "Event Hub Namespace SKU."
  type        = string
  default     = "Standard"
}

variable "random_suffix" {
  description = "Random suffix used for test uniqueness."
  type        = string
  default     = ""
}
