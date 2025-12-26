variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}

variable "yaml_path" {
  description = "Path to the pipeline YAML file."
  type        = string
  default     = "azure-pipelines.yml"
}

variable "service_endpoint_url" {
  description = "Service endpoint URL."
  type        = string
  default     = "https://example.endpoint.local"
}

variable "service_endpoint_username" {
  description = "Service endpoint username."
  type        = string
  default     = "example-user"
}

variable "service_endpoint_password" {
  description = "Service endpoint password."
  type        = string
  default     = "example-password"
  sensitive   = true
}
