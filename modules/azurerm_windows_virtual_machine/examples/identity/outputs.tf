output "windows_virtual_machine_id" {
  description = "The ID of the created Windows Virtual Machine"
  value       = module.windows_virtual_machine.id
}

output "windows_virtual_machine_name" {
  description = "The name of the created Windows Virtual Machine"
  value       = module.windows_virtual_machine.name
}
