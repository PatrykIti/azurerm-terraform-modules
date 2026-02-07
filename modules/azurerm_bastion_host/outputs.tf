output "id" {
  description = "The ID of the Bastion Host."
  value       = azurerm_bastion_host.bastion_host.id
}

output "name" {
  description = "The name of the Bastion Host."
  value       = azurerm_bastion_host.bastion_host.name
}

output "resource_group_name" {
  description = "The resource group name of the Bastion Host."
  value       = azurerm_bastion_host.bastion_host.resource_group_name
}

output "location" {
  description = "The location of the Bastion Host."
  value       = azurerm_bastion_host.bastion_host.location
}

output "sku" {
  description = "The SKU of the Bastion Host."
  value       = azurerm_bastion_host.bastion_host.sku
}

output "dns_name" {
  description = "The FQDN of the Bastion Host."
  value       = try(azurerm_bastion_host.bastion_host.dns_name, null)
}

output "ip_configuration" {
  description = "The IP configuration for the Bastion Host."
  value       = try(azurerm_bastion_host.bastion_host.ip_configuration, null)
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log categories, log category groups, or metric categories were resolved."
  value       = local.diagnostic_settings_skipped
}
