variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-ampls-basic-example"
}

variable "scope_name" {
  description = "Name of the Azure Monitor Private Link Scope."
  type        = string
  default     = "ampls-basic-example"
}
