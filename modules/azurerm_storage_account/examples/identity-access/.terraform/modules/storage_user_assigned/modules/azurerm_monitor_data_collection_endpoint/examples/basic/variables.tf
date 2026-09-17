variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-dce-basic-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "endpoint_name" {
  description = "Data Collection Endpoint name (must be globally unique)."
  type        = string
  default     = "dcebasicexample001"
}
