# Virtual Network Core Outputs
output "id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.id
}

output "name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.name
}

output "location" {
  description = "The Azure Region where the Virtual Network exists."
  value       = azurerm_virtual_network.virtual_network.location
}

output "resource_group_name" {
  description = "The name of the resource group containing the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.resource_group_name
}

output "address_space" {
  description = "The address space of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.address_space
}

output "dns_servers" {
  description = "The DNS servers configured for the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.dns_servers
}

output "guid" {
  description = "The GUID of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.guid
}

# Subnet Information
output "subnet" {
  description = "Information about subnets defined within the Virtual Network (if any)."
  value       = azurerm_virtual_network.virtual_network.subnet
}





# Network Configuration Summary
output "network_configuration" {
  description = "Summary of Virtual Network configuration."
  value = {
    name                    = azurerm_virtual_network.virtual_network.name
    id                      = azurerm_virtual_network.virtual_network.id
    address_space           = azurerm_virtual_network.virtual_network.address_space
    dns_servers             = azurerm_virtual_network.virtual_network.dns_servers
    flow_timeout_in_minutes = azurerm_virtual_network.virtual_network.flow_timeout_in_minutes
    bgp_community           = azurerm_virtual_network.virtual_network.bgp_community
    edge_zone               = azurerm_virtual_network.virtual_network.edge_zone
    ddos_protection_enabled = var.ddos_protection_plan != null ? var.ddos_protection_plan.enable : false
    encryption_enabled      = var.encryption != null
  }
}