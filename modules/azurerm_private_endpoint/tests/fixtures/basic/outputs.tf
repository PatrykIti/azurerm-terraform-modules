output "private_endpoint_id" {
  description = "The ID of the created Private Endpoint."
  value       = module.private_endpoint.id
}

output "private_endpoint_name" {
  description = "The name of the created Private Endpoint."
  value       = module.private_endpoint.name
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.example.name
}

output "private_endpoint_private_ip" {
  description = "The private IP address allocated to the Private Endpoint."
  value       = module.private_endpoint.private_ip_address
}
