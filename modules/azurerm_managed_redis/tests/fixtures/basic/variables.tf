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
  description = "Managed Redis SKU for the basic fixture."
  type        = string
  default     = "Balanced_B3"
}

variable "tags" {
  description = "Tags to apply to the Managed Redis instance."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Basic"
  }
}
