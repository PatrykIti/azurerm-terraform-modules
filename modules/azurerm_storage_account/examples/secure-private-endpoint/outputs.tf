output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.secure_storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.secure_storage.name
}

output "private_endpoints" {
  description = "Details of the private endpoints"
  value       = module.secure_storage.private_endpoints
}

output "private_endpoint_subnet_id" {
  description = "The ID of the subnet used for private endpoints"
  value       = azurerm_subnet.private_endpoints.id
}

output "private_dns_zones" {
  description = "The private DNS zones created for storage services"
  value = {
    blob  = azurerm_private_dns_zone.blob.name
    file  = azurerm_private_dns_zone.file.name
    queue = azurerm_private_dns_zone.queue.name
    table = azurerm_private_dns_zone.table.name
  }
}

output "identity_principal_id" {
  description = "The principal ID of the storage account's managed identity"
  value       = module.secure_storage.identity.principal_id
}

output "key_vault_id" {
  description = "The ID of the Key Vault used for encryption"
  value       = azurerm_key_vault.example.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostics"
  value       = azurerm_log_analytics_workspace.example.id
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "security_configuration" {
  description = "Summary of security settings applied"
  value = {
    https_only                      = true
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    shared_key_enabled              = true # Required for Terraform management
    infrastructure_encryption       = var.enable_infrastructure_encryption
    network_default_action          = "Deny"
    private_endpoints_enabled       = true
    customer_managed_key            = true
    diagnostic_logging              = true
    versioning_enabled              = true
    change_feed_enabled             = true
    advanced_threat_protection      = var.enable_advanced_threat_protection
    network_flow_logs               = var.enable_network_flow_logs
    policy_compliance               = var.enable_azure_policy_compliance
  }
}

output "network_security" {
  description = "Network security configuration details"
  value = {
    vnets = {
      id            = azurerm_virtual_network.example.id
      address_space = azurerm_virtual_network.example.address_space
    }
    nsgs = {
      private_endpoints_nsg = azurerm_network_security_group.private_endpoints.id
      app_nsg               = azurerm_network_security_group.app.id
    }
    flow_logs_enabled = var.enable_network_flow_logs
    ddos_protection   = var.enable_ddos_protection
  }
}

output "monitoring_configuration" {
  description = "Monitoring and alerting configuration"
  value = {
    action_group_id         = azurerm_monitor_action_group.security.id
    log_analytics_id        = azurerm_log_analytics_workspace.example.id
    application_insights_id = azurerm_application_insights.security.id
    defender_enabled        = var.enable_advanced_threat_protection
    key_rotation_days       = var.key_rotation_reminder_days
  }
}

output "compliance_status" {
  description = "Policy compliance configuration"
  value = var.enable_azure_policy_compliance ? {
    policies_assigned = [
      "Customer-managed key encryption",
      "HTTPS only traffic",
      "Network restrictions",
      "Private endpoints usage",
      "Infrastructure encryption",
      "Minimum TLS 1.2"
    ]
  } : null
}

output "key_vault_configuration" {
  description = "Key Vault configuration for encryption"
  value = {
    key_vault_id   = azurerm_key_vault.example.id
    key_vault_name = azurerm_key_vault.example.name
    key_id         = azurerm_key_vault_key.storage.id
    key_rotation   = "Every 90 days with ${var.key_rotation_reminder_days} days reminder"
  }
}

output "deployment_instructions" {
  description = "Post-deployment security recommendations"
  value       = <<-EOT
    Secure Storage Deployment Complete!
    
    Security Checklist:
    ✓ Infrastructure encryption: ${var.enable_infrastructure_encryption ? "Enabled" : "Disabled"}
    ✓ Advanced Threat Protection: ${var.enable_advanced_threat_protection ? "Enabled" : "Disabled"}
    ✓ Network Flow Logs: ${var.enable_network_flow_logs ? "Enabled" : "Disabled"}
    ✓ Azure Policy Compliance: ${var.enable_azure_policy_compliance ? "Enabled" : "Disabled"}
    ✓ DDoS Protection: ${var.enable_ddos_protection ? "Enabled" : "Disabled"}
    
    Next Steps:
    1. Review security alerts in action group: ${azurerm_monitor_action_group.security.name}
    2. Check policy compliance in Azure Policy dashboard
    3. Configure data classification labels
    4. Set up regular security reviews
    5. Test disaster recovery procedures
    
    Security Best Practices:
    - Rotate encryption keys every 90 days
    - Review access logs weekly
    - Update allowed IP ranges sparingly
    - Enable Microsoft Defender for all production workloads
    - Conduct penetration testing annually
  EOT
}