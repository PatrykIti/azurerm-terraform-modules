variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}