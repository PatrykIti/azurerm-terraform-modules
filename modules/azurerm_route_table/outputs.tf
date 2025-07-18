# Core Route Table Outputs
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

# Route Configuration
output "routes" {
  description = "Map of routes within the Route Table, keyed by route name."
  value       = azurerm_route.routes
}

output "bgp_route_propagation_enabled" {
  description = "Whether BGP route propagation is enabled on the Route Table"
  value       = azurerm_route_table.route_table.bgp_route_propagation_enabled
}

# Subnet Associations
output "subnet_associations" {
  description = "Map of subnet IDs to their association IDs"
  value = {
    for subnet_id, association in azurerm_subnet_route_table_association.associations :
    subnet_id => association.id
  }
}

output "associated_subnet_ids" {
  description = "List of subnet IDs associated with this Route Table"
  value       = keys(azurerm_subnet_route_table_association.associations)
}

# Tags
output "tags" {
  description = "The tags assigned to the Route Table"
  value       = azurerm_route_table.route_table.tags
}