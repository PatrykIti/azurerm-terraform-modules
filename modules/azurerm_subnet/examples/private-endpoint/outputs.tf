# Private Endpoint Subnet outputs
output "private_endpoint_subnet_id" {
  description = "The ID of the private endpoint subnet"
  value       = module.subnet_private_endpoint.id
}

output "private_endpoint_subnet_name" {
  description = "The name of the private endpoint subnet"
  value       = module.subnet_private_endpoint.name
}

output "private_endpoint_subnet_address_prefixes" {
  description = "The address prefixes of the private endpoint subnet"
  value       = module.subnet_private_endpoint.address_prefixes
}

output "private_endpoint_network_policies_enabled" {
  description = "Network policies status for private endpoints"
  value       = module.subnet_private_endpoint.private_endpoint_network_policies_enabled
}

# Resources Subnet outputs
output "resources_subnet_id" {
  description = "The ID of the resources subnet"
  value       = module.subnet_resources.id
}

output "resources_subnet_name" {
  description = "The name of the resources subnet"
  value       = module.subnet_resources.name
}

# Private Endpoint configuration
output "storage_private_endpoint_id" {
  description = "The ID of the storage private endpoint"
  value       = azurerm_private_endpoint.storage.id
}

output "storage_private_endpoint_ip" {
  description = "The private IP address of the storage private endpoint"
  value       = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.example.id
}

# DNS Configuration
output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.storage_blob.id
}

output "private_dns_zone_name" {
  description = "The name of the private DNS zone"
  value       = azurerm_private_dns_zone.storage_blob.name
}

# Supporting resources
output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}