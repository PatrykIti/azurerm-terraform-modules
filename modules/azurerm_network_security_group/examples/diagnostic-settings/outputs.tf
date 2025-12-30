output "network_security_group_id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "diagnostic_settings_ids" {
  description = "Map of diagnostic settings names to their IDs."
  value       = module.network_security_group.diagnostic_settings_ids
}
