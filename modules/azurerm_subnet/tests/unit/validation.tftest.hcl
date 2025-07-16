# Input Validation Tests

# Mock the azurerm provider
mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    }
  }
}

# Test: Valid subnet name
run "test_valid_subnet_name" {
  command = plan

  variables {
    name                 = "valid-subnet-name-123"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "valid-subnet-name-123"
    error_message = "Subnet should accept valid name"
  }
}

# Test: Empty subnet name validation
run "test_empty_subnet_name_validation" {
  command = plan
  
  variables {
    name                 = ""
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
  }

  expect_failures = [
    var.name
  ]
}

# Test: Valid IPv4 address prefix
run "test_valid_ipv4_address_prefix" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
  }

  assert {
    condition     = azurerm_subnet.subnet.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Subnet should accept valid IPv4 CIDR"
  }
}

# Test: Valid IPv6 address prefix
run "test_valid_ipv6_address_prefix" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["2001:db8::/64"]
  }

  assert {
    condition     = azurerm_subnet.subnet.address_prefixes[0] == "2001:db8::/64"
    error_message = "Subnet should accept valid IPv6 CIDR"
  }
}

# Test: Invalid address prefix validation
run "test_invalid_address_prefix_validation" {
  command = plan
  
  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["not-a-valid-cidr"]
  }

  expect_failures = [
    var.address_prefixes
  ]
}

# Test: Empty address prefixes validation
run "test_empty_address_prefixes_validation" {
  command = plan
  
  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = []
  }

  expect_failures = [
    var.address_prefixes
  ]
}

# Test: Valid service endpoint
run "test_valid_service_endpoint" {
  command = plan

  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    service_endpoints    = ["Microsoft.Storage"]
  }

  assert {
    condition     = contains(azurerm_subnet.subnet.service_endpoints, "Microsoft.Storage")
    error_message = "Subnet should accept valid service endpoint"
  }
}

# Test: Invalid service endpoint validation
run "test_invalid_service_endpoint_validation" {
  command = plan
  
  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    service_endpoints    = ["Microsoft.InvalidService"]
  }

  expect_failures = [
    var.service_endpoints
  ]
}

# Test: Valid delegation
run "test_valid_delegation" {
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
          actions = []
        }
      }
    }
  }

  assert {
    condition     = azurerm_subnet.subnet.delegation[0].service_delegation[0].name == "Microsoft.ContainerInstance/containerGroups"
    error_message = "Subnet should accept valid delegation"
  }
}

# Test: Invalid delegation validation
run "test_invalid_delegation_validation" {
  command = plan
  
  variables {
    name                 = "test-subnet"
    resource_group_name  = "test-rg"
    virtual_network_name = "test-vnet"
    address_prefixes     = ["10.0.1.0/24"]
    delegations = {
      invalid = {
        name = "Invalid.Service/type"
        service_delegation = {
          name = "Invalid.Service/type"
          actions = []
        }
      }
    }
  }

  expect_failures = [
    var.delegations
  ]
}