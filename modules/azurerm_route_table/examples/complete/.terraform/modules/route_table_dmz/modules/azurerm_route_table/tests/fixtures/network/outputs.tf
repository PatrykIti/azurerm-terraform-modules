output "route_table_name" {
  description = "The name of the hub route table (for test compatibility)."
  value       = module.hub_route_table.name
}

output "hub_route_table_id" {
  description = "The ID of the hub Route Table."
  value       = module.hub_route_table.id
}

output "spoke1_route_table_id" {
  description = "The ID of the spoke1 Route Table."
  value       = module.spoke1_route_table.id
}

output "spoke2_route_table_id" {
  description = "The ID of the spoke2 Route Table."
  value       = module.spoke2_route_table.id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.test.name
}

output "hub_nva_ip" {
  description = "IP address of the hub NVA."
  value       = azurerm_network_interface.hub_nva.private_ip_address
}

output "vnets" {
  description = "Information about created VNets."
  value = {
    hub = {
      id            = azurerm_virtual_network.hub.id
      name          = azurerm_virtual_network.hub.name
      address_space = azurerm_virtual_network.hub.address_space
    }
    spoke1 = {
      id            = azurerm_virtual_network.spoke1.id
      name          = azurerm_virtual_network.spoke1.name
      address_space = azurerm_virtual_network.spoke1.address_space
    }
    spoke2 = {
      id            = azurerm_virtual_network.spoke2.id
      name          = azurerm_virtual_network.spoke2.name
      address_space = azurerm_virtual_network.spoke2.address_space
    }
  }
}

output "peering_connections" {
  description = "List of VNet peering connections."
  value = [
    azurerm_virtual_network_peering.hub_to_spoke1.name,
    azurerm_virtual_network_peering.spoke1_to_hub.name,
    azurerm_virtual_network_peering.hub_to_spoke2.name,
    azurerm_virtual_network_peering.spoke2_to_hub.name
  ]
}

output "associated_subnet_ids" {
  description = "IDs of subnets associated with route tables"
  value = [
    azurerm_subnet.hub_shared.id,
    azurerm_subnet.spoke1_workload.id,
    azurerm_subnet.spoke2_workload.id
  ]
}