# ==============================================================================
# Secure Storage Account with Private Endpoints - Variables
# ==============================================================================

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "West Europe"
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "secure"
}

variable "enable_advanced_threat_protection" {
  description = "Enable Microsoft Defender for Storage (Advanced Threat Protection)"
  type        = bool
  default     = true
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher for network diagnostics"
  type        = bool
  default     = true
}

variable "enable_ddos_protection" {
  description = "Enable DDoS Protection Standard on the virtual network"
  type        = bool
  default     = false # Due to high cost, disabled by default
}

variable "key_rotation_reminder_days" {
  description = "Days before key expiration to send reminder"
  type        = number
  default     = 30
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access storage (use with caution in production)"
  type        = list(string)
  default     = []
}

variable "enable_infrastructure_encryption" {
  description = "Enable infrastructure encryption for double encryption at rest"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 90
}

variable "enable_private_endpoint_policies" {
  description = "Enable network policies on private endpoint subnet"
  type        = bool
  default     = false # Must be false for private endpoints
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment        = "Production"
    SecurityLevel      = "Maximum"
    DataClassification = "Confidential"
    ManagedBy          = "Terraform"
  }
}

variable "enable_azure_policy_compliance" {
  description = "Enable Azure Policy assignments for compliance"
  type        = bool
  default     = true
}

variable "enable_key_vault_monitoring" {
  description = "Enable detailed monitoring for Key Vault operations"
  type        = bool
  default     = true
}

variable "enable_network_flow_logs" {
  description = "Enable NSG flow logs for network traffic analysis"
  type        = bool
  default     = true
}

variable "storage_account_tier" {
  description = "Performance tier for the storage account"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be either Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Invalid replication type specified."
  }
}