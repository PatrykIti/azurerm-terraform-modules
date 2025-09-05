output "subnet_id" {
  description = "The ID of the created subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the subnet"
  value       = module.subnet.address_prefixes
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.test_vnet.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.test_vnet.id
}
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}
