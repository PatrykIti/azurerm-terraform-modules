variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "West Europe"
}

variable "random_suffix" {
  type        = string
  description = "Random suffix for resource naming"
  default     = ""
}