variable "project_id" {
  type = string
}

variable "generic_endpoint_name_prefix" {
  type    = string
  default = "ado-generic-secure"
}

variable "generic_endpoint_url" {
  type    = string
  default = "https://example.endpoint.local"
}

variable "generic_endpoint_username" {
  type    = string
  default = "example-user"
}

variable "generic_endpoint_password" {
  type      = string
  default   = "example-password"
  sensitive = true
}
