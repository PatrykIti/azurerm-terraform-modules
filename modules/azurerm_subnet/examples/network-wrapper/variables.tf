variable "name_suffix" {
  description = "Suffix to append to resource names for uniqueness"
  type        = string
  default     = "example"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Example"
    ManagedBy   = "Terraform"
    Purpose     = "NetworkWrapper"
  }
}