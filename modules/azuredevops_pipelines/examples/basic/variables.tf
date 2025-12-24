variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repo_name_prefix" {
  description = "Prefix for the repository name."
  type        = string
  default     = "ado-pipeline-repo"
}

variable "pipeline_name_prefix" {
  description = "Prefix for the pipeline name."
  type        = string
  default     = "ado-pipeline"
}

variable "yaml_path" {
  description = "Path to the pipeline YAML file."
  type        = string
  default     = "azure-pipelines.yml"
}
