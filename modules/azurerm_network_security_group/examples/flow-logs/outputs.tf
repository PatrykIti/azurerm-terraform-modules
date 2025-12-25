output "network_security_group_id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "flow_log" {
  description = "Flow log configuration for the NSG."
  value       = module.network_security_group.flow_log
}
