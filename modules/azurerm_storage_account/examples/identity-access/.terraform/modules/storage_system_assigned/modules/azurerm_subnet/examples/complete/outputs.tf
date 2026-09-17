# Outputs for Complete Subnet Example

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the created subnet"
  value       = module.subnet.address_prefixes
}

output "subnet_service_endpoints" {
  description = "The service endpoints enabled on the subnet"
  value       = module.subnet.service_endpoints
}

output "subnet_service_endpoint_policy_ids" {
  description = "The service endpoint policy IDs associated with the subnet"
  value       = module.subnet.service_endpoint_policy_ids
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group associated with the subnet"
  value       = azurerm_network_security_group.example.id
}

output "route_table_id" {
  description = "The ID of the Route Table associated with the subnet"
  value       = azurerm_route_table.example.id
}

output "storage_account_id" {
  description = "The ID of the Storage Account used for service endpoint policy demo"
  value       = azurerm_storage_account.example.id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}