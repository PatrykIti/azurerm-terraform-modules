# Basic Subnet Module Tests

# Mock the azurerm provider
mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
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
    error_message = "Expected exactly one address prefix"
  }
}

# Test: Default values
run "test_default_values" {
  command = plan

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies_enabled == true
    error_message = "Private endpoint network policies should be enabled by default"
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == true
    error_message = "Private link service network policies should be enabled by default"
  }

  assert {
    condition     = length(azurerm_subnet.subnet.service_endpoints) == 0
    error_message = "Service endpoints should be empty by default"
  }
}