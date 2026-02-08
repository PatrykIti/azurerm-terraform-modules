output "id" {
  description = "The ID of the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.id, null)
}

output "name" {
  description = "The name of the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.name, null)
}

output "location" {
  description = "The location of the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.location, null)
}

output "resource_group_name" {
  description = "The resource group name of the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.resource_group_name, null)
}

output "default_hostname" {
  description = "The default hostname of the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.default_hostname, null)
}

output "identity" {
  description = "The managed identity information for the Linux Function App."
  value = try({
    principal_id = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
    tenant_id    = azurerm_linux_function_app.linux_function_app.identity[0].tenant_id
    type         = azurerm_linux_function_app.linux_function_app.identity[0].type
  }, null)
}

output "outbound_ip_addresses" {
  description = "The outbound IP addresses for the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.outbound_ip_addresses, null)
}

output "outbound_ip_address_list" {
  description = "The outbound IP address list for the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.outbound_ip_address_list, null)
}

output "possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses for the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.possible_outbound_ip_addresses, null)
}

output "possible_outbound_ip_address_list" {
  description = "The possible outbound IP address list for the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.possible_outbound_ip_address_list, null)
}

output "slots" {
  description = "Map of Linux Function App slots keyed by name."
  value = {
    for slot_name, slot in azurerm_linux_function_app_slot.linux_function_app_slot : slot_name => {
      id               = slot.id
      name             = slot.name
      default_hostname = slot.default_hostname
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log categories/groups or metric categories were supplied."
  value = [
    for ds in var.diagnostic_settings : {
      name                = ds.name
      log_categories      = ds.log_categories
      log_category_groups = ds.log_category_groups
      metric_categories   = ds.metric_categories
    }
    if(
      length(coalesce(ds.log_categories, [])) +
      length(coalesce(ds.log_category_groups, [])) +
      length(coalesce(ds.metric_categories, []))
    ) == 0
  ]
}

output "tags" {
  description = "The tags assigned to the Linux Function App."
  value       = try(azurerm_linux_function_app.linux_function_app.tags, null)
}
