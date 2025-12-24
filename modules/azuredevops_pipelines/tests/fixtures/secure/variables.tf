variable "project_id" {
  type = string
}

variable "repo_name_prefix" {
  type    = string
  default = "ado-secure-repo"
}

variable "pipeline_name_prefix" {
  type    = string
  default = "ado-secure-pipeline"
}

variable "yaml_path" {
  type    = string
  default = "azure-pipelines.yml"
}

variable "service_endpoint_name_prefix" {
  type    = string
  default = "ado-secure-endpoint"
}

variable "service_endpoint_url" {
  type    = string
  default = "https://example.endpoint.local"
}

variable "service_endpoint_username" {
  type    = string
  default = "example-user"
}

variable "service_endpoint_password" {
  type      = string
  default   = "example-password"
  sensitive = true
}
