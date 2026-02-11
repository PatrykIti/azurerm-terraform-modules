variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "random_suffix" {
  description = "Random suffix for unique resource naming"
  type        = string
}
