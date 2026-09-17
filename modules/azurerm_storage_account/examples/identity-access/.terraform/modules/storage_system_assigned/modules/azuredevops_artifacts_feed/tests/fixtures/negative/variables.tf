variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "feed_name_prefix" {
  description = "Prefix for feed names."
  type        = string
  default     = "ado-feed-negative"
}
