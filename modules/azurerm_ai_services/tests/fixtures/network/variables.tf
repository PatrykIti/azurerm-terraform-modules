variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "allowed_ip_range" {
  description = "IP range allowed to access the AI Services Account."
  type        = string
  default     = "203.0.113.0/24"
}

variable "tags" {
  description = "Tags to apply to the AI Services Account."
  type        = map(string)
  default = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
