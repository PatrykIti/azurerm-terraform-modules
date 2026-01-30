# Virtual Network Core Outputs
output "id" {
  description = "The ID of the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.id, null)
}

output "name" {
  description = "The name of the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.name, null)
}

output "location" {
  description = "The Azure Region where the Virtual Network exists."
  value       = try(azurerm_virtual_network.virtual_network.location, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.resource_group_name, null)
}

output "address_space" {
  description = "The address space of the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.address_space, null)
}

output "dns_servers" {
  description = "The DNS servers configured for the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.dns_servers, null)
}

output "guid" {
  description = "The GUID of the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.guid, null)
}

# Subnet Information
output "subnet" {
  description = "Information about subnets defined within the Virtual Network (if any)."
  value       = try(azurerm_virtual_network.virtual_network.subnet, null)
}

# Network Configuration Summary
output "network_configuration" {
  description = "Summary of Virtual Network configuration."
  value = try({
    name                    = azurerm_virtual_network.virtual_network.name
    id                      = azurerm_virtual_network.virtual_network.id
    address_space           = azurerm_virtual_network.virtual_network.address_space
    dns_servers             = azurerm_virtual_network.virtual_network.dns_servers
    flow_timeout_in_minutes = azurerm_virtual_network.virtual_network.flow_timeout_in_minutes
    bgp_community           = azurerm_virtual_network.virtual_network.bgp_community
    edge_zone               = azurerm_virtual_network.virtual_network.edge_zone
    ddos_protection_enabled = var.ddos_protection_plan != null && var.ddos_protection_plan.enable
    encryption_enabled      = var.encryption != null
  }, null)
}
