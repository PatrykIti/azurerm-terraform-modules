# Outputs for Basic Subnet Example

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

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}