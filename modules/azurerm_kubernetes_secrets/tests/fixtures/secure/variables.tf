variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "northeurope"
}

variable "random_suffix" {
  description = "Random suffix for unique resource naming"
  type        = string
}
