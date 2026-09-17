# Outputs for Private Endpoint Subnet Example

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created subnet"
  value       = module.subnet.name
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.example.id
}

output "storage_account_id" {
  description = "The ID of the storage account used for the private endpoint"
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
