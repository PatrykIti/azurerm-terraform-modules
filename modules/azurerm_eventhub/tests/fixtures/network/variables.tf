variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-eh-network-example"
}

variable "namespace_name" {
  description = "Event Hub Namespace name for the example."
  type        = string
  default     = "ehnsnetwork001"
}

variable "eventhub_name" {
  description = "Event Hub name for the example."
  type        = string
  default     = "eh-network"
}

variable "random_suffix" {
  description = "Random suffix used for test uniqueness."
  type        = string
  default     = ""
}
