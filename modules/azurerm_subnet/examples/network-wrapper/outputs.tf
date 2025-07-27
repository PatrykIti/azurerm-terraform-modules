# Subnet Outputs
output "subnet_app_id" {
  description = "ID of the application subnet"
  value       = module.subnet_app.id
}

output "subnet_data_id" {
  description = "ID of the data subnet"
  value       = module.subnet_data.id
}

output "subnet_management_id" {
  description = "ID of the management subnet"
  value       = module.subnet_management.id
}

# NSG Association Outputs
output "nsg_association_app_id" {
  description = "ID of the app subnet NSG association"
  value       = azurerm_subnet_network_security_group_association.app.id
}

output "nsg_association_data_id" {
  description = "ID of the data subnet NSG association"
  value       = azurerm_subnet_network_security_group_association.data.id
}

# Route Table Association Outputs
output "route_table_association_app_id" {
  description = "ID of the app subnet route table association"
  value       = azurerm_subnet_route_table_association.app.id
}

output "route_table_association_data_id" {
  description = "ID of the data subnet route table association"
  value       = azurerm_subnet_route_table_association.data.id
}