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

variable "account_name" {
  description = "Azure Storage account name for the queue hook."
  type        = string
}

variable "account_key" {
  description = "Azure Storage account key for the queue hook."
  type        = string
  sensitive   = true
}

variable "queue_name" {
  description = "Azure Storage queue name for the queue hook."
  type        = string
}
