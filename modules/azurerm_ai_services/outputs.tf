output "id" {
  description = "The ID of the AI Services Account."
  value       = azurerm_ai_services.ai_services.id
}

output "name" {
  description = "The name of the AI Services Account."
  value       = azurerm_ai_services.ai_services.name
}

output "resource_group_name" {
  description = "The resource group name of the AI Services Account."
  value       = azurerm_ai_services.ai_services.resource_group_name
}

output "location" {
  description = "The location of the AI Services Account."
  value       = azurerm_ai_services.ai_services.location
}

output "sku_name" {
  description = "The SKU name of the AI Services Account."
  value       = azurerm_ai_services.ai_services.sku_name
}

output "endpoint" {
  description = "The endpoint of the AI Services Account."
  value       = try(azurerm_ai_services.ai_services.endpoint, null)
}

output "fqdns" {
  description = "The allowed FQDNs for the AI Services Account."
  value       = try(azurerm_ai_services.ai_services.fqdns, null)
}

output "public_network_access" {
  description = "The public network access setting for the AI Services Account."
  value       = try(azurerm_ai_services.ai_services.public_network_access, null)
}

output "identity" {
  description = "The managed identity configuration for the AI Services Account."
  value = try({
    type         = azurerm_ai_services.ai_services.identity[0].type
    principal_id = azurerm_ai_services.ai_services.identity[0].principal_id
    tenant_id    = azurerm_ai_services.ai_services.identity[0].tenant_id
    identity_ids = azurerm_ai_services.ai_services.identity[0].identity_ids
  }, null)
}

output "primary_access_key" {
  description = "The primary access key for the AI Services Account."
  value       = try(azurerm_ai_services.ai_services.primary_access_key, null)
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the AI Services Account."
  value       = try(azurerm_ai_services.ai_services.secondary_access_key, null)
  sensitive   = true
}

output "diagnostic_settings_skipped" {
  description = "Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped."
  value       = []
}
