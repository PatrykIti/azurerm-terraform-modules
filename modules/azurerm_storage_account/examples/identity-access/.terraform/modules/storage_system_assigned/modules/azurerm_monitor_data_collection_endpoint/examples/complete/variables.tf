variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-dce-complete-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "endpoint_name" {
  description = "Data Collection Endpoint name (must be globally unique)."
  type        = string
  default     = "dcecompleteexample001"
}

variable "kind" {
  description = "The kind of the Data Collection Endpoint."
  type        = string
  default     = "Linux"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Data Collection Endpoint."
  type        = bool
  default     = true
}

variable "description" {
  description = "Description for the Data Collection Endpoint."
  type        = string
  default     = "Complete Data Collection Endpoint example."
}
