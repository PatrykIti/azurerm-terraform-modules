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

output "bgp_route_propagation_enabled" {
  description = "Whether BGP route propagation is enabled on the Route Table."
  value       = module.route_table.bgp_route_propagation_enabled
}
