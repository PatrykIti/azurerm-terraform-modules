variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "collection_group_name" {
  description = "Collection-level group name to grant permissions."
  type        = string
  default     = "Project Collection Administrators"
}
