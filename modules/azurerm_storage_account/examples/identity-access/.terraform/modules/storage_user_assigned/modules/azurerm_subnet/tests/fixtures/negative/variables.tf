variable "subscription_id" {
  description = "Azure subscription ID for testing"
  type        = string
}

variable "subnet_suffix" {
  description = "Random suffix for subnet name"
  type        = string
  default     = ""
}