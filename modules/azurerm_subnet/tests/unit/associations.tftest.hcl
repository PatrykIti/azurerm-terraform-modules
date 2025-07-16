# NSG and Route Table Association Tests

# Mock the azurerm provider
mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    }
  }

  mock_resource "azurerm_subnet_network_security_group_association" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet/networkSecurityGroups/test-nsg"
    }
  }

  mock_resource "azurerm_subnet_route_table_association" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet/routeTables/test-rt"
    }
  }
}

# Test: NSG Association
run "test_nsg_association" {
  command = plan

  variables {
    name                      = "test-subnet"
    resource_group_name       = "test-rg"
    virtual_network_name      = "test-vnet"
    address_prefixes          = ["10.0.1.0/24"]
    network_security_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.subnet) == 1
    error_message = "NSG association should be created when network_security_group_id is provided"
  }

  assert {
    condition     = azurerm_subnet_network_security_group_association.subnet[0].network_security_group_id == var.network_security_group_id
    error_message = "NSG association should use the provided NSG ID"
  }

  assert {
    condition     = output.network_security_group_id == var.network_security_group_id
    error_message = "NSG ID output should match the input"
  }

  assert {
    condition     = output.network_security_group_association_id != null
    error_message = "NSG association ID output should not be null"
  }
}

# Test: Route Table Association
run "test_route_table_association" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    route_table_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
  }

  assert {
    condition     = length(azurerm_subnet_route_table_association.subnet) == 1
    error_message = "Route table association should be created when route_table_id is provided"
  }

  assert {
    condition     = azurerm_subnet_route_table_association.subnet[0].route_table_id == var.route_table_id
    error_message = "Route table association should use the provided route table ID"
  }

  assert {
    condition     = output.route_table_id == var.route_table_id
    error_message = "Route table ID output should match the input"
  }

  assert {
    condition     = output.route_table_association_id != null
    error_message = "Route table association ID output should not be null"
  }
}

# Test: Both NSG and Route Table Associations
run "test_both_associations" {
  command = plan

  variables {
    name                      = "test-subnet"
    resource_group_name       = "test-rg"
    virtual_network_name      = "test-vnet"
    address_prefixes          = ["10.0.1.0/24"]
    network_security_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    route_table_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.subnet) == 1
    error_message = "NSG association should be created"
  }

  assert {
    condition     = length(azurerm_subnet_route_table_association.subnet) == 1
    error_message = "Route table association should be created"
  }

  assert {
    condition     = output.network_security_group_association_id != null
    error_message = "NSG association ID should not be null"
  }

  assert {
    condition     = output.route_table_association_id != null
    error_message = "Route table association ID should not be null"
  }
}