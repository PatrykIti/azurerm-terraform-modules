variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Storage account name (must be globally unique)."
  type        = string
  default     = "stvnetsecureexample"
}
