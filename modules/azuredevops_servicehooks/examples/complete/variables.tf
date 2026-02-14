variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "webhook_url" {
  description = "Webhook URL for service hook delivery."
  type        = string
}

variable "pipeline_name" {
  description = "Pipeline name to filter build completed events."
  type        = string
}
