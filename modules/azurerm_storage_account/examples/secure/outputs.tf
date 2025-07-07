output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint (accessible only via private endpoint)"
  value       = module.storage_account.primary_blob_endpoint
}

output "identity_principal_id" {
  description = "The principal ID of the storage account's system-assigned identity"
  value       = module.storage_account.identity.principal_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs"
  value       = module.storage_account.private_endpoints
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.example.vault_uri
}

output "encryption_key_id" {
  description = "The ID of the encryption key"
  value       = azurerm_key_vault_key.storage.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for security monitoring"
  value       = azurerm_log_analytics_workspace.example.id
}

output "security_alert_id" {
  description = "The ID of the authentication failure alert"
  value       = azurerm_monitor_metric_alert.storage_auth_failures.id
}

# Security Configuration Summary
output "security_configuration" {
  description = "Summary of security settings applied to the storage account"
  value = {
    oauth_authentication_default     = true
    shared_access_keys_enabled       = false
    public_network_access            = false
    https_traffic_only               = true
    min_tls_version                  = "TLS1_2"
    infrastructure_encryption        = true
    allowed_copy_scope               = "PrivateLink"
    cross_tenant_replication_enabled = false
    queue_encryption_key_type        = "Account"
    table_encryption_key_type        = "Account"
    private_endpoints_count          = length(module.storage_account.private_endpoints)
    customer_managed_key_enabled     = true
    key_rotation_enabled             = true
    audit_logging_enabled            = true
    soft_delete_retention_days       = 365
  }
}

output "network_security_status" {
  description = "Network security configuration status"
  value = {
    network_rules_default_action = "Deny"
    bypass_rules                 = []
    allowed_ip_rules             = []
    allowed_subnets              = []
    private_endpoint_services    = ["blob", "web", "dfs"]
  }
}