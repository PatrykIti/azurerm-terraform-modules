output "linux_virtual_machine_id" {
  description = "The ID of the Linux VM"
  value       = module.linux_virtual_machine.id
}

output "linux_virtual_machine_name" {
  description = "The name of the Linux VM"
  value       = module.linux_virtual_machine.name
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.example.name
}
