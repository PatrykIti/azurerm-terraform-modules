output "network_security_group_id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "network_security_group_name" {
  description = "The name of the created Network Security Group."
  value       = module.network_security_group.name
}

output "security_rule_ids" {
  description = "Map of security rule names to their IDs."
  value       = module.network_security_group.security_rule_ids
}

output "location" {
  description = "The location of the Network Security Group."
  value       = module.network_security_group.location
}