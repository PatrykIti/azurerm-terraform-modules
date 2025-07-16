# ==============================================================================
# Multi-Region Storage Account Example Variables
# ==============================================================================

variable "primary_location" {
  description = "Primary region for the storage account deployment"
  type        = string
  default     = "West Europe"
}

variable "secondary_location" {
  description = "Secondary region for backup storage"
  type        = string
  default     = "North Europe"
}

variable "dr_location" {
  description = "Disaster recovery region for archive storage"
  type        = string
  default     = "UK South"
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "multi-region"
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for all storage accounts"
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for storage account access"
  type        = list(string)
  default     = []
}

variable "enable_replication_automation" {
  description = "Enable automated replication using Azure Function or Logic App"
  type        = bool
  default     = false
}

variable "replication_schedule" {
  description = "CRON expression for replication schedule (if automation enabled)"
  type        = string
  default     = "0 */6 * * *" # Every 6 hours
}

variable "enable_monitoring_alerts" {
  description = "Enable monitoring alerts for replication lag and failures"
  type        = bool
  default     = true
}

variable "replication_lag_threshold_minutes" {
  description = "Threshold in minutes for replication lag alerts"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Example    = "Multi-Region"
    ManagedBy  = "Terraform"
    CostCenter = "Infrastructure"
  }
}