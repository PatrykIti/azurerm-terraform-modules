output "virtual_network_id" {
  description = "The ID of the created Virtual Network"
  value       = module.virtual_network.id
}

output "virtual_network_name" {
  description = "The name of the created Virtual Network"
  value       = module.virtual_network.name
}

output "virtual_network_address_space" {
  description = "The address space of the created Virtual Network"
  value       = module.virtual_network.address_space
}

output "virtual_network_dns_links" {
  description = "Information about Private DNS Zone links"
  value       = module.virtual_network.private_dns_zone_links
}

output "private_endpoint_subnet_id" {
  description = "The ID of the private endpoint subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "workload_subnet_id" {
  description = "The ID of the workload subnet"
  value       = azurerm_subnet.workloads.id
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.example.id
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.storage.id
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.blob.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.example.location
}
