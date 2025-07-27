output "route_table_id" {
  description = "The ID of the created Route Table."
  value       = module.route_table.id
}

output "route_table_name" {
  description = "The name of the created Route Table."
  value       = module.route_table.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the route table was created."
  value       = azurerm_resource_group.test.name
}

output "routes" {
  description = "Map of routes within the Route Table."
  value       = module.route_table.routes
}

output "security_appliance_ip" {
  description = "IP address of the security appliance used for routing."
  value       = azurerm_network_interface.security_appliance.private_ip_address
}

output "subnet_associations" {
  description = "List of subnet IDs associated with the secure route table."
  value = [
    azurerm_subnet.app.id,
    azurerm_subnet.db.id
  ]
}

output "security_routes_count" {
  description = "Number of security routes configured."
  value       = length(module.route_table.routes)
}
