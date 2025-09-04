# Outputs for Simplified Secure Subnet Example

output "subnet_id" {
  description = "The ID of the created secure subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created secure subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the created secure subnet"
  value       = module.subnet.address_prefixes
}

output "subnet_service_endpoints" {
  description = "The service endpoints enabled on the secure subnet"
  value       = module.subnet.service_endpoints
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group associated with the secure subnet"
  value       = azurerm_network_security_group.secure.id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}