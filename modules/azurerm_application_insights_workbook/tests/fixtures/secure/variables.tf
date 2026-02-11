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
