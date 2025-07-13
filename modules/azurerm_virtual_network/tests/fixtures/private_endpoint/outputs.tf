output "virtual_network_id" {
  description = "The ID of the created Virtual Network"
  value       = module.virtual_network.id
}

output "virtual_network_name" {
  description = "The name of the created Virtual Network"
  value       = module.virtual_network.name
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.virtual_network.private_endpoints
}
