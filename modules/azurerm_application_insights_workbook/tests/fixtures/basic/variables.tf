variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "Random suffix for resource naming in tests"
  type        = string
  default     = "test"
}

variable "tags" {
  description = "Tags applied to test resources"
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Basic"
  }
}
