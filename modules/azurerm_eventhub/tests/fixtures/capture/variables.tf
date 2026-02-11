variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-eh-capture-example"
}

variable "namespace_name" {
  description = "Event Hub Namespace name for the example."
  type        = string
  default     = "ehnscaptureexample001"
}

variable "eventhub_name" {
  description = "Event Hub name for the example."
  type        = string
  default     = "eh-capture"
}

variable "storage_account_name" {
  description = "Storage account name for capture."
  type        = string
  default     = "stehcapture002"
}

variable "random_suffix" {
  description = "Random suffix used for test uniqueness."
  type        = string
  default     = ""
}
