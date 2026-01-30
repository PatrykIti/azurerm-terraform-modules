output "id" {
  description = "The ID of the Windows Virtual Machine."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.id, null)
}

output "name" {
  description = "The name of the Windows Virtual Machine."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.name, null)
}

output "location" {
  description = "The location of the Windows Virtual Machine."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.location, null)
}

output "resource_group_name" {
  description = "The resource group name of the Windows Virtual Machine."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.resource_group_name, null)
}

output "network_interface_ids" {
  description = "Network interface IDs attached to the VM."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.network_interface_ids, null)
}

output "private_ip_address" {
  description = "Primary private IP address of the VM (when available)."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.private_ip_address, null)
}

output "private_ip_addresses" {
  description = "All private IP addresses associated with the VM."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.private_ip_addresses, null)
}

output "public_ip_address" {
  description = "Primary public IP address of the VM (when available)."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.public_ip_address, null)
}

output "public_ip_addresses" {
  description = "All public IP addresses associated with the VM."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.public_ip_addresses, null)
}

output "virtual_machine_id" {
  description = "The unique Virtual Machine ID."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.virtual_machine_id, null)
}

output "identity" {
  description = "The managed identity of the VM (if configured)."
  value       = try(azurerm_windows_virtual_machine.windows_virtual_machine.identity[0], null)
}

output "extensions" {
  description = "VM extensions created by the module."
  value = {
    for name, extension in azurerm_virtual_machine_extension.virtual_machine_extensions : name => {
      id   = extension.id
      name = extension.name
    }
  }
}

output "data_disks" {
  description = "Managed data disks created by the module."
  value = {
    for name, disk in azurerm_managed_disk.data_disks : name => {
      id   = disk.id
      name = disk.name
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value       = local.diagnostic_settings_skipped
}
