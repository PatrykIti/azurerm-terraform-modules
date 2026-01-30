variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "aad_client_id" {
  description = "Azure AD application client ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "aad_tenant_endpoint" {
  description = "Azure AD tenant endpoint (v2)."
  type        = string
  default     = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0"
}

variable "aad_client_secret" {
  description = "Azure AD application client secret."
  type        = string
  default     = "example-secret"
  sensitive   = true
}
