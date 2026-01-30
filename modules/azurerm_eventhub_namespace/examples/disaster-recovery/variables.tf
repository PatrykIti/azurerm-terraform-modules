variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-ehns-dr-example"
}

variable "primary_namespace_name" {
  description = "Primary Event Hub Namespace name."
  type        = string
  default     = "ehnsprimarydr001"
}

variable "secondary_namespace_name" {
  description = "Secondary Event Hub Namespace name."
  type        = string
  default     = "ehnssecondarydr001"
}
