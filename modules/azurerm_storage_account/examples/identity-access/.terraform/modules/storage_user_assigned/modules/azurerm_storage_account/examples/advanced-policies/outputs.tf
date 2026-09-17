# Storage Account outputs
output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "The primary Data Lake Storage Gen2 endpoint"
  value       = module.storage_account.primary_dfs_endpoint
}

# Policy-related outputs
output "immutability_policy_state" {
  description = "The state of the immutability policy"
  value       = local.immutability_policy.state
}

output "sas_expiration_period" {
  description = "The SAS token expiration period"
  value       = local.sas_policy.expiration_period
}

output "routing_choice" {
  description = "The routing preference choice"
  value       = local.routing.choice
}

output "custom_domain" {
  description = "The custom domain configuration"
  value       = local.custom_domain.name
  sensitive   = false
}

output "smb_multichannel_enabled" {
  description = "Whether SMB Multichannel is enabled"
  value       = local.share_properties.smb.multichannel_enabled
}

# Internet routing endpoints (when using InternetRouting)
output "internet_routing_enabled" {
  description = "Whether internet routing is enabled"
  value       = local.routing.choice == "InternetRouting"
}

# Compliance and security status
output "compliance_features" {
  description = "Summary of compliance and security features enabled"
  value = {
    immutability_enabled = local.immutability_policy != null
    sas_policy_enabled   = local.sas_policy != null
    sftp_enabled         = true
    hns_enabled          = true
    custom_domain        = local.custom_domain != null
  }
}