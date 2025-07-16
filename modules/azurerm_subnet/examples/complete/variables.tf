variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "northeurope"
}

variable "name_suffix" {
  description = "Suffix for resource names to ensure uniqueness"
  type        = string
  default     = "002"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Complete"
    Module      = "azurerm_subnet"
  }
}