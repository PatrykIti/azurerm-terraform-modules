output "id" {
  description = "The ID of the Linux Virtual Machine."
  value       = try(azurerm_linux_virtual_machine.linux_virtual_machine.id, null)
}

output "name" {
  description = "The name of the Linux Virtual Machine."
  value       = try(azurerm_linux_virtual_machine.linux_virtual_machine.name, null)
}

output "location" {
  description = "The location of the Linux Virtual Machine."
  value       = try(azurerm_linux_virtual_machine.linux_virtual_machine.location, null)
}

output "resource_group_name" {
  description = "The resource group name of the Linux Virtual Machine."
  value       = try(azurerm_linux_virtual_machine.linux_virtual_machine.resource_group_name, null)
}

output "network_interface_ids" {
  description = "Network interface IDs attached to the VM."
  value       = try(azurerm_linux_virtual_machine.linux_virtual_machine.network_interface_ids, null)
}

output "identity" {
  description = "The managed identity of the VM (if configured)."
  value       = try(azurerm_linux_virtual_machine.linux_virtual_machine.identity[0], null)
}

output "extensions" {
  description = "VM extensions created by the module."
  value = {
    for name, extension in azurerm_virtual_machine_extension.virtual_machine_extension : name => {
      id   = extension.id
      name = extension.name
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped."
  value       = []
}
