variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "sku_name" {
  description = "SKU name for the App Service Plan."
  type        = string
  default     = "B1"
}

variable "os_type" {
  description = "Operating system type for the App Service Plan."
  type        = string
  default     = "Windows"
}

variable "tags" {
  description = "Tags to apply to the App Service Plan."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Basic"
  }
}
