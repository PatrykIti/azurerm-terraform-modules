output "network_security_group_id" {
  description = "The ID of the created Network Security Group"
  value       = module.network_security_group.id
}

output "network_security_group_name" {
  description = "The name of the created Network Security Group"
  value       = module.network_security_group.name
}
