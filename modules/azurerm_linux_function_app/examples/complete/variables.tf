variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "aad_client_id" {
  description = "Azure AD application client ID for auth_settings example."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "aad_client_secret" {
  description = "Azure AD application client secret for auth_settings example."
  type        = string
  default     = "example-secret"
  sensitive   = true
}
