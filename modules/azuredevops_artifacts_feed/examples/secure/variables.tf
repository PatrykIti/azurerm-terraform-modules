variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "feed_name" {
  description = "Feed name."
  type        = string
  default     = "secure-feed"
}

variable "principal_descriptor" {
  description = "Principal descriptor for feed permissions."
  type        = string
}
