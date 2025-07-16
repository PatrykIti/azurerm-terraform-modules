# Basic Subnet Module Tests
# Tests for basic subnet creation functionality

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

variables {
  name                 = "test-subnet"
  resource_group_name  = "test-rg"
  virtual_network_name = "test-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}

# Test: Basic subnet creation
run "test_basic_subnet_creation" {
  command = plan

  assert {
    condition     = azurerm_subnet.subnet.name == var.name
    error_message = "Subnet name does not match expected value"
  }

  assert {
    condition     = azurerm_subnet.subnet.resource_group_name == var.resource_group_name
    error_message = "Resource group name does not match expected value"
  }

  assert {
    condition     = azurerm_subnet.subnet.virtual_network_name == var.virtual_network_name
    error_message = "Virtual network name does not match expected value"
  }

  assert {
    condition     = length(azurerm_subnet.subnet.address_prefixes) == 1
    error_message = "Subnet should have exactly one address prefix"
  }

  assert {
    condition     = azurerm_subnet.subnet.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Address prefix does not match expected value"
  }
}

# Test: Default network policies
run "test_default_network_policies" {
  command = plan

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies == "Enabled"
    error_message = "Private endpoint network policies should be enabled by default"
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == true
    error_message = "Private link service network policies should be enabled by default"
  }
}

# Test: No associations by default
run "test_no_associations_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.subnet) == 0
    error_message = "No NSG association should exist by default"
  }

  assert {
    condition     = length(azurerm_subnet_route_table_association.subnet) == 0
    error_message = "No route table association should exist by default"
  }
}

# Test: Output values
run "test_subnet_outputs" {
  command = apply

  assert {
    condition     = output.id != null
    error_message = "Subnet ID output should not be null"
  }

  assert {
    condition     = output.name == var.name
    error_message = "Subnet name output should match input"
  }

  assert {
    condition     = output.resource_group_name == var.resource_group_name
    error_message = "Resource group name output should match input"
  }

  assert {
    condition     = output.virtual_network_name == var.virtual_network_name
    error_message = "Virtual network name output should match input"
  }

  assert {
    condition     = length(output.address_prefixes) == 1
    error_message = "Address prefixes output should have one element"
  }
}