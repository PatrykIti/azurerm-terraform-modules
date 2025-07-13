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

# Subnet outputs
output "subnet_web_id" {
  description = "The ID of the Web subnet"
  value       = azurerm_subnet.web.id
}

output "subnet_app_id" {
  description = "The ID of the App subnet"
  value       = azurerm_subnet.app.id
}

output "subnet_firewall_id" {
  description = "The ID of the Firewall subnet"
  value       = azurerm_subnet.firewall.id
}

# NSG outputs
output "network_security_group_web_id" {
  description = "The ID of the Web NSG"
  value       = azurerm_network_security_group.web.id
}

output "network_security_group_app_id" {
  description = "The ID of the App NSG"
  value       = azurerm_network_security_group.app.id
}

# Route Table outputs
output "route_table_web_id" {
  description = "The ID of the Web route table"
  value       = azurerm_route_table.web.id
}

output "route_table_app_id" {
  description = "The ID of the App route table"
  value       = azurerm_route_table.app.id
}

# Association outputs
output "subnet_nsg_association_web_id" {
  description = "The ID of the Web subnet-NSG association"
  value       = azurerm_subnet_network_security_group_association.web.id
}

output "subnet_nsg_association_app_id" {
  description = "The ID of the App subnet-NSG association"
  value       = azurerm_subnet_network_security_group_association.app.id
}

output "subnet_route_table_association_web_id" {
  description = "The ID of the Web subnet-route table association"
  value       = azurerm_subnet_route_table_association.web.id
}

output "subnet_route_table_association_app_id" {
  description = "The ID of the App subnet-route table association"
  value       = azurerm_subnet_route_table_association.app.id
}

# Resource Group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "location" {
  description = "The Azure region where resources were created"
  value       = azurerm_resource_group.test.location
}