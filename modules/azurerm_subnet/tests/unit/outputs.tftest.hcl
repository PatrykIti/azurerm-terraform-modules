# Test output validation for the Subnet module

mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id                                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/testsubnet"
      name                                          = "testsubnet"
      virtual_network_name                          = "test-vnet"
      resource_group_name                           = "test-rg"
      address_prefixes                              = ["10.0.1.0/24"]
      service_endpoints                             = []
      service_endpoint_policy_ids                  = []
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

# Test basic outputs
run "verify_basic_outputs" {
  command = apply

  override_resource {
    target = azurerm_subnet.subnet
    values = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/testsubnet"
      name                 = "testsubnet"
      virtual_network_name = "test-vnet"
      resource_group_name  = "test-rg"
      address_prefixes     = ["10.0.1.0/24"]
    }
  }

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/testsubnet"
    error_message = "ID output should be the full resource ID"
  }

  assert {
    condition     = output.name == "testsubnet"
    error_message = "Name output should match the subnet name"
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Resource group name output should be correct"
  }

  assert {
    condition     = output.virtual_network_name == "test-vnet"
    error_message = "Virtual network name output should be correct"
  }

  assert {
    condition     = output.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Address prefixes output should be correct"
  }
}

# Test service endpoints outputs
run "verify_service_endpoints_outputs" {
  command = apply

  variables {
    service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
  }

  override_resource {
    target = azurerm_subnet.subnet
    values = {
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
  }

  assert {
    condition     = length(output.service_endpoints) == 2
    error_message = "Service endpoints output should contain 2 endpoints"
  }

  assert {
    condition     = contains(output.service_endpoints, "Microsoft.Storage")
    error_message = "Service endpoints output should contain Microsoft.Storage"
  }

  assert {
    condition     = contains(output.service_endpoints, "Microsoft.Sql")
    error_message = "Service endpoints output should contain Microsoft.Sql"
  }
}

# Test network policies outputs with default values
run "verify_network_policies_outputs" {
  command = apply

  override_resource {
    target = azurerm_subnet.subnet
    values = {
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
    }
  }

  assert {
    condition     = output.private_endpoint_network_policies_enabled == true
    error_message = "Private endpoint network policies enabled output should be true when policies are 'Enabled'"
  }

  assert {
    condition     = output.private_link_service_network_policies_enabled == true
    error_message = "Private link service network policies enabled output should be true"
  }
}

# Test delegations output
run "verify_delegations_output" {
  command = apply

  variables {
    delegations = {
      "aci" = {
        name = "aci-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }

  assert {
    condition     = output.delegations != null
    error_message = "Delegations output should not be null"
  }

  assert {
    condition     = output.delegations["aci"].name == "Microsoft.ContainerInstance/containerGroups"
    error_message = "Delegations output should contain the correct service delegation name"
  }
}