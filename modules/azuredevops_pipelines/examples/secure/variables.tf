variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repo_name_prefix" {
  description = "Prefix for the repository name."
  type        = string
  default     = "ado-secure-repo"
}

variable "pipeline_name_prefix" {
  description = "Prefix for the pipeline name."
  type        = string
  default     = "ado-secure-pipeline"
}

variable "yaml_path" {
  description = "Path to the pipeline YAML file."
  type        = string
  default     = "azure-pipelines.yml"
}

variable "service_endpoint_name_prefix" {
  description = "Prefix for the service endpoint name."
  type        = string
  default     = "ado-secure-endpoint"
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
  sensitive   = true
}
