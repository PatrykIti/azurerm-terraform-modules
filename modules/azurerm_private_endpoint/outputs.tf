output "id" {
  description = "The ID of the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.id, null)
}

output "name" {
  description = "The name of the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.name, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.resource_group_name, null)
}

output "location" {
  description = "The Azure region where the Private Endpoint exists."
  value       = try(azurerm_private_endpoint.main.location, null)
}

output "subnet_id" {
  description = "The subnet ID from which the Private Endpoint IP address is allocated."
  value       = try(azurerm_private_endpoint.main.subnet_id, null)
}

output "custom_network_interface_name" {
  description = "The custom network interface name, if configured."
  value       = try(azurerm_private_endpoint.main.custom_network_interface_name, null)
}

output "network_interface" {
  description = "The network interface details created for the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.network_interface, [])
}

output "private_service_connection" {
  description = "The private service connection configuration and computed values."
  value       = try(azurerm_private_endpoint.main.private_service_connection, [])
}

output "private_ip_address" {
  description = "The private IP address allocated to the service connection (if available)."
  value       = try(azurerm_private_endpoint.main.private_service_connection[0].private_ip_address, null)
}

output "ip_configuration" {
  description = "The configured static IP configuration blocks."
  value       = try(azurerm_private_endpoint.main.ip_configuration, [])
}

output "private_dns_zone_group" {
  description = "The private DNS zone group configuration on the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.private_dns_zone_group, [])
}

output "custom_dns_configs" {
  description = "The custom DNS configurations associated with the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.custom_dns_configs, [])
}

output "private_dns_zone_configs" {
  description = "The private DNS zone configurations associated with the Private Endpoint."
  value       = try(azurerm_private_endpoint.main.private_dns_zone_configs, [])
}
