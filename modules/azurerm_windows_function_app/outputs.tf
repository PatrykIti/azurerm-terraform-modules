output "id" {
  description = "The ID of the Windows Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.id, null)
}

output "name" {
  description = "The name of the Windows Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.name, null)
}

output "location" {
  description = "The location of the Windows Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.location, null)
}

output "resource_group_name" {
  description = "The resource group name of the Windows Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.resource_group_name, null)
}

output "default_hostname" {
  description = "The default hostname of the Windows Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.default_hostname, null)
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses for the Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.outbound_ip_addresses, null)
}

output "possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses for the Function App."
  value       = try(azurerm_windows_function_app.windows_function_app.possible_outbound_ip_addresses, null)
}

output "identity" {
  description = "Managed identity information."
  value = try({
    type         = azurerm_windows_function_app.windows_function_app.identity[0].type
    principal_id = azurerm_windows_function_app.windows_function_app.identity[0].principal_id
    tenant_id    = azurerm_windows_function_app.windows_function_app.identity[0].tenant_id
    identity_ids = try(azurerm_windows_function_app.windows_function_app.identity[0].identity_ids, null)
  }, null)
}

output "slots" {
  description = "Slot details keyed by slot name."
  value = {
    for name, slot in azurerm_windows_function_app_slot.windows_function_app_slot : name => {
      id               = slot.id
      name             = slot.name
      default_hostname = try(slot.default_hostname, null)
    }
  }
}
