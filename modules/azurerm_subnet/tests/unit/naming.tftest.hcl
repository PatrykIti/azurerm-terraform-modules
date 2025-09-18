# Test naming conventions for the Subnet module

mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
      name                 = "test-subnet"
      virtual_network_name = "test-vnet"
      resource_group_name  = "test-rg"
      address_prefixes     = ["10.0.1.0/24"]
    }
  }
}

variables {
  resource_group_name  = "test-rg"
  virtual_network_name = "test-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}

# Test valid subnet name
run "valid_subnet_name" {
  command = plan

  variables {
    name = "valid-subnet-name"
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "valid-subnet-name"
    error_message = "Subnet name should be set correctly"
  }
}

# Test maximum length subnet name (80 characters)
run "max_length_subnet_name" {
  command = plan

  variables {
    name = "a${join("", [for i in range(79) : "a"])}" # Creates 80 character string
  }

  assert {
    condition     = length(azurerm_subnet.subnet.name) == 80
    error_message = "Subnet should accept names up to 80 characters"
  }
}

# Test subnet name with numbers and hyphens
run "subnet_name_with_special_chars" {
  command = plan

  variables {
    name = "subnet-01-prod"
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "subnet-01-prod"
    error_message = "Subnet name should accept numbers and hyphens"
  }
}

# Test subnet name with underscores
run "subnet_name_with_underscores" {
  command = plan

  variables {
    name = "subnet_01_prod"
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "subnet_01_prod"
    error_message = "Subnet name should accept underscores"
  }
}

# Test subnet name with mixed case
run "subnet_name_mixed_case" {
  command = plan

  variables {
    name = "SubnetProdEastUs"
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "SubnetProdEastUs"
    error_message = "Subnet name should preserve mixed case"
  }
}