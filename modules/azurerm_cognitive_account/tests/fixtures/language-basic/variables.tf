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
  description = "SKU name for the Cognitive Account."
  type        = string
  default     = "F0"
}

variable "tags" {
  description = "Tags to apply to the Cognitive Account."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Language"
  }
}
