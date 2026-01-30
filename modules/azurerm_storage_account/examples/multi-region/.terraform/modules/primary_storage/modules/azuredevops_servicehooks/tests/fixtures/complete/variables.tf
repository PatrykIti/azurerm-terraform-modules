variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "webhook_url" {
  description = "Webhook URL for service hook delivery."
  type        = string
  default     = "https://example.com/webhook"
}

variable "account_name" {
  description = "Azure Storage account name for the queue hook."
  type        = string
  default     = "exampleaccount"
}

variable "account_key" {
  description = "Azure Storage account key for the queue hook."
  type        = string
  default     = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  sensitive   = true
}

variable "queue_name" {
  description = "Azure Storage queue name for the queue hook."
  type        = string
  default     = "example-queue"
}
