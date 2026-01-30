variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "description" {
  description = "Description for the Data Collection Endpoint."
  type        = string
  default     = "Secure Data Collection Endpoint fixture."
}

variable "tags" {
  description = "Tags to apply to the Data Collection Endpoint."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Secure"
  }
}
