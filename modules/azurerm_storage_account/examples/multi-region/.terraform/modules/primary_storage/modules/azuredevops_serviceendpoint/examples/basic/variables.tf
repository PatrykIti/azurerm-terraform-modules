variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "generic_endpoint_name" {
  description = "Generic service endpoint name."
  type        = string
  default     = "ado-generic-basic"
}

variable "generic_endpoint_url" {
  description = "Generic service endpoint URL."
  type        = string
  default     = "https://example.endpoint.local"
}

variable "generic_endpoint_username" {
  description = "Generic service endpoint username."
  type        = string
  default     = "example-user"
}

variable "generic_endpoint_password" {
  description = "Generic service endpoint password."
  type        = string
  sensitive   = true
}
