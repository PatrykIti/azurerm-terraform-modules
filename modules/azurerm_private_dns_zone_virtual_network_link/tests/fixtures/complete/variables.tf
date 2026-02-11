variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to the Private DNS Zone Virtual Network Link."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Complete"
  }
}
