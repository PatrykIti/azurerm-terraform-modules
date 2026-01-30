output "windows_virtual_machine_id" {
  description = "The ID of the Windows VM"
  value       = module.windows_virtual_machine.id
}

output "windows_virtual_machine_name" {
  description = "The name of the Windows VM"
  value       = module.windows_virtual_machine.name
}

output "extensions" {
  description = "VM extensions"
  value       = module.windows_virtual_machine.extensions
}
