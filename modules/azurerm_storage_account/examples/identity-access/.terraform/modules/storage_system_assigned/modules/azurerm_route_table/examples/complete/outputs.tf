# Complete Route Table Outputs
output "complete_route_table" {
  description = "All outputs from the complete route table module"
  value = {
    id                            = module.route_table_complete.id
    name                          = module.route_table_complete.name
    location                      = module.route_table_complete.location
    resource_group_name           = module.route_table_complete.resource_group_name
    bgp_route_propagation_enabled = module.route_table_complete.bgp_route_propagation_enabled
    routes                        = module.route_table_complete.routes
    tags                          = module.route_table_complete.tags
  }
}

# DMZ Route Table Outputs
output "dmz_route_table" {
  description = "All outputs from the DMZ route table module"
  value = {
    id                            = module.route_table_dmz.id
    name                          = module.route_table_dmz.name
    bgp_route_propagation_enabled = module.route_table_dmz.bgp_route_propagation_enabled
    routes                        = module.route_table_dmz.routes
  }
}

# Supporting Resource Outputs
output "virtual_network" {
  description = "Virtual network details"
  value = {
    id            = azurerm_virtual_network.example.id
    name          = azurerm_virtual_network.example.name
    address_space = azurerm_virtual_network.example.address_space
  }
}

output "subnets" {
  description = "All subnet details"
  value = {
    app = {
      id               = azurerm_subnet.app.id
      name             = azurerm_subnet.app.name
      address_prefixes = azurerm_subnet.app.address_prefixes
    }
    data = {
      id               = azurerm_subnet.data.id
      name             = azurerm_subnet.data.name
      address_prefixes = azurerm_subnet.data.address_prefixes
    }
    firewall = {
      id               = azurerm_subnet.firewall.id
      name             = azurerm_subnet.firewall.name
      address_prefixes = azurerm_subnet.firewall.address_prefixes
    }
  }
}

output "subnet_route_table_associations" {
  description = "Subnet to route table associations"
  value = {
    app = {
      id             = azurerm_subnet_route_table_association.app.id
      subnet_id      = azurerm_subnet_route_table_association.app.subnet_id
      route_table_id = azurerm_subnet_route_table_association.app.route_table_id
    }
    data = {
      id             = azurerm_subnet_route_table_association.data.id
      subnet_id      = azurerm_subnet_route_table_association.data.subnet_id
      route_table_id = azurerm_subnet_route_table_association.data.route_table_id
    }
  }
}