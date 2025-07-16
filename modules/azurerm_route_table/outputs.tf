output "id" {
  description = "The ID of the Route Table"
  value       = azurerm_route_table.route_table.id
}

output "name" {
  description = "The name of the Route Table"
  value       = azurerm_route_table.route_table.name
}

output "location" {
  description = "The location of the Route Table"
  value       = azurerm_route_table.route_table.location
}

output "resource_group_name" {
  description = "The name of the resource group containing the Route Table"
  value       = azurerm_route_table.route_table.resource_group_name
}