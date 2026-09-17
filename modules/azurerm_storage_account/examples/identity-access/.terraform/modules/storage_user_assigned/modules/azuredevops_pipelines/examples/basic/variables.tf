variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repo_name" {
  description = "Name of the repository."
  type        = string
  default     = "ado-pipelines-repo-basic-example"
}

variable "pipeline_name" {
  description = "Name of the pipeline."
  type        = string
  default     = "ado-pipelines-basic-example"
}

variable "yaml_path" {
  description = "Path to the pipeline YAML file."
  type        = string
  default     = "azure-pipelines.yml"
}
