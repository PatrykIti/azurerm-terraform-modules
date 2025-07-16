# Service Endpoints and Delegation Tests

# Mock the azurerm provider
mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    }
  }
}

# Test: Service Endpoints
run "test_service_endpoints" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    service_endpoints    = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
  }

  assert {
    condition     = length(azurerm_subnet.subnet.service_endpoints) == 3
    error_message = "Subnet should have three service endpoints"
  }

  assert {
    condition     = contains(azurerm_subnet.subnet.service_endpoints, "Microsoft.Storage")
    error_message = "Subnet should have Microsoft.Storage service endpoint"
  }

  assert {
    condition     = contains(azurerm_subnet.subnet.service_endpoints, "Microsoft.Sql")
    error_message = "Subnet should have Microsoft.Sql service endpoint"
  }

  assert {
    condition     = contains(azurerm_subnet.subnet.service_endpoints, "Microsoft.KeyVault")
    error_message = "Subnet should have Microsoft.KeyVault service endpoint"
  }

  assert {
    condition     = length(output.service_endpoints) == 3
    error_message = "Service endpoints output should have three elements"
  }
}

# Test: Service Endpoint Policies
run "test_service_endpoint_policies" {
  command = plan

  variables {
    name                        = "test-subnet"
    resource_group_name         = "test-rg"
    virtual_network_name        = "test-vnet"
    address_prefixes            = ["10.0.1.0/24"]
    service_endpoints           = ["Microsoft.Storage"]
    service_endpoint_policy_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/serviceEndpointPolicies/test-policy1",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/serviceEndpointPolicies/test-policy2"
    ]
  }

  assert {
    condition     = length(azurerm_subnet.subnet.service_endpoint_policy_ids) == 2
    error_message = "Subnet should have two service endpoint policies"
  }

  assert {
    condition     = length(output.service_endpoint_policy_ids) == 2
    error_message = "Service endpoint policy IDs output should have two elements"
  }
}

# Test: Subnet Delegation
run "test_subnet_delegation" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    delegations = {
      aci = {
        name = "Microsoft.ContainerInstance/containerGroups"
        service_delegation = {
          name = "Microsoft.ContainerInstance/containerGroups"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action",
            "Microsoft.Network/virtualNetworks/subnets/join/action"
          ]
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_subnet.subnet.delegation) == 1
    error_message = "Subnet should have one delegation"
  }

  assert {
    condition     = azurerm_subnet.subnet.delegation[0].name == "aci"
    error_message = "Delegation name should be 'aci'"
  }

  assert {
    condition     = azurerm_subnet.subnet.delegation[0].service_delegation[0].name == "Microsoft.ContainerInstance/containerGroups"
    error_message = "Service delegation name should be Microsoft.ContainerInstance/containerGroups"
  }

  assert {
    condition     = length(azurerm_subnet.subnet.delegation[0].service_delegation[0].actions) == 2
    error_message = "Service delegation should have two actions"
  }

  assert {
    condition     = length(output.delegations) == 1
    error_message = "Delegations output should have one element"
  }
}

# Test: Multiple Delegations (should work with dynamic block)
run "test_multiple_delegations" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    delegations = {
      databricks = {
        name = "Microsoft.Databricks/workspaces"
        service_delegation = {
          name    = "Microsoft.Databricks/workspaces"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_subnet.subnet.delegation) == 1
    error_message = "Subnet should have one delegation"
  }

  assert {
    condition     = azurerm_subnet.subnet.delegation[0].name == "databricks"
    error_message = "Delegation name should be 'databricks'"
  }
}