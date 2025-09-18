# Test default settings for the Subnet module

mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id                                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
      name                                          = "test-subnet"
      virtual_network_name                          = "test-vnet"
      resource_group_name                           = "test-rg"
      address_prefixes                              = ["10.0.1.0/24"]
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = false
    }
  }
}

variables {
  name                 = "testsubnet"
  resource_group_name  = "test-rg"
  virtual_network_name = "test-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}

# Test default network policies
run "verify_default_network_policies" {
  command = plan

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies == "Enabled"
    error_message = "Default private endpoint network policies should be Enabled (default value is true)"
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == true
    error_message = "Default private link service network policies should be enabled (default value is true)"
  }
}

# Test default service endpoints (should be empty)
run "verify_default_service_endpoints" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.subnet.service_endpoints) == 0
    error_message = "Default service endpoints should be empty"
  }
}

# Test default delegations (should be empty)
run "verify_default_delegations" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.subnet.delegation) == 0
    error_message = "Default delegations should be empty"
  }
}

# Test with network policies disabled
run "verify_network_policies_disabled" {
  command = plan

  variables {
    private_endpoint_network_policies_enabled     = false
    private_link_service_network_policies_enabled = false
  }

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies == "Disabled"
    error_message = "Private endpoint network policies should be Disabled when explicitly set to false"
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == false
    error_message = "Private link service network policies should be disabled when explicitly set to false"
  }
}