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
  description = "Description for the Data Collection Rule."
  type        = string
  default     = "Complete Data Collection Rule fixture."
}

variable "tags" {
  description = "Tags to apply to the Data Collection Rule."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Complete"
  }
}
