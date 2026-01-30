variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges for network ACLs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the Cognitive Account."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Complete"
  }
}
