# Network Policies Tests

# Mock the azurerm provider
mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    }
  }
}

# Test: Private Endpoint Network Policies
run "test_private_endpoint_policies_enabled" {
  command = plan

  variables {
    name                                      = "test-subnet"
    resource_group_name                       = "test-rg"
    virtual_network_name                      = "test-vnet"
    address_prefixes                          = ["10.0.1.0/24"]
    private_endpoint_network_policies_enabled = true
  }

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies == "Enabled"
    error_message = "Private endpoint network policies should be enabled"
  }

  assert {
    condition     = output.private_endpoint_network_policies_enabled == true
    error_message = "Private endpoint network policies output should be true"
  }
}

run "test_private_endpoint_policies_disabled" {
  command = plan

  variables {
    name                                      = "test-subnet"
    resource_group_name                       = "test-rg"
    virtual_network_name                      = "test-vnet"
    address_prefixes                          = ["10.0.1.0/24"]
    private_endpoint_network_policies_enabled = false
  }

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies == "Disabled"
    error_message = "Private endpoint network policies should be disabled"
  }

  assert {
    condition     = output.private_endpoint_network_policies_enabled == false
    error_message = "Private endpoint network policies output should be false"
  }
}

# Test: Private Link Service Network Policies
run "test_private_link_service_policies_enabled" {
  command = plan

  variables {
    name                                          = "test-subnet"
    resource_group_name                           = "test-rg"
    virtual_network_name                          = "test-vnet"
    address_prefixes                              = ["10.0.1.0/24"]
    private_link_service_network_policies_enabled = true
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == true
    error_message = "Private link service network policies should be enabled"
  }

  assert {
    condition     = output.private_link_service_network_policies_enabled == true
    error_message = "Private link service network policies output should be true"
  }
}

run "test_private_link_service_policies_disabled" {
  command = plan

  variables {
    name                                          = "test-subnet"
    resource_group_name                           = "test-rg"
    virtual_network_name                          = "test-vnet"
    address_prefixes                              = ["10.0.1.0/24"]
    private_link_service_network_policies_enabled = false
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == false
    error_message = "Private link service network policies should be disabled"
  }

  assert {
    condition     = output.private_link_service_network_policies_enabled == false
    error_message = "Private link service network policies output should be false"
  }
}

# Test: Both policies disabled for private endpoint subnet
run "test_private_endpoint_subnet_configuration" {
  command = plan

  variables {
    name                                          = "test-pe-subnet"
    resource_group_name                           = "test-rg"
    virtual_network_name                          = "test-vnet"
    address_prefixes                              = ["10.0.1.0/24"]
    private_endpoint_network_policies_enabled     = false
    private_link_service_network_policies_enabled = false
  }

  assert {
    condition     = azurerm_subnet.subnet.private_endpoint_network_policies == "Disabled"
    error_message = "Private endpoint network policies should be disabled for PE subnet"
  }

  assert {
    condition     = azurerm_subnet.subnet.private_link_service_network_policies_enabled == false
    error_message = "Private link service network policies should be disabled for PE subnet"
  }
}