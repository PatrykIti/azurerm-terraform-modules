variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-dcr-complete-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "data_collection_rule_name" {
  description = "Data Collection Rule name (must be globally unique)."
  type        = string
  default     = "dcrcompleteexample001"
}

variable "data_collection_endpoint_name" {
  description = "Data Collection Endpoint name (must be globally unique)."
  type        = string
  default     = "dcecompleteexample001"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name for the example."
  type        = string
  default     = "lawdcrcompleteexample001"
}

variable "description" {
  description = "Description for the Data Collection Rule."
  type        = string
  default     = "Complete Data Collection Rule example."
}

variable "kind" {
  description = "The kind of the Data Collection Rule."
  type        = string
  default     = "Windows"
}
