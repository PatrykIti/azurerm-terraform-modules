variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "admin_source_ip_address" {
  description = "The source IP address for administrative access (e.g., SSH)."
  type        = string
  default     = "10.0.0.0/16" # Replace with your actual IP or a more restrictive range
}