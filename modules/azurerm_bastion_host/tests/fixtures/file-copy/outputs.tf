output "bastion_host_id" {
  description = "The ID of the created Bastion Host"
  value       = module.bastion_host.id
}

output "bastion_host_name" {
  description = "The name of the created Bastion Host"
  value       = module.bastion_host.name
}
