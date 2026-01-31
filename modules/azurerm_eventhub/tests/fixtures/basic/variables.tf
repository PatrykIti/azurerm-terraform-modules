variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-eh-basic-example"
}

variable "namespace_name" {
  description = "Event Hub Namespace name for the example."
  type        = string
  default     = "ehnsbasicforhub001"
}

variable "eventhub_name" {
  description = "Event Hub name for the example."
  type        = string
  default     = "eh-basic"
}

variable "partition_count" {
  description = "Number of partitions for the Event Hub."
  type        = number
  default     = 2
}

variable "message_retention" {
  description = "Number of days to retain events."
  type        = number
  default     = 1
}

variable "status" {
  description = "Status of the Event Hub."
  type        = string
  default     = "Active"
}

variable "random_suffix" {
  description = "Random suffix used for test uniqueness."
  type        = string
  default     = ""
}
