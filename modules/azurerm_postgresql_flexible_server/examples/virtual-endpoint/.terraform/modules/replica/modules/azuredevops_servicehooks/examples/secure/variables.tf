variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "webhook_url" {
  description = "Webhook URL for service hook delivery."
  type        = string
}

variable "principal_descriptor" {
  description = "Principal descriptor for service hook permissions."
  type        = string
}

variable "area_path" {
  description = "Area path for work item filters."
  type        = string
  default     = ""
}
