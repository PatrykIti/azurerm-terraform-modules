variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "northeurope"
}

variable "random_suffix" {
  description = "Random suffix for unique resource naming"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}
