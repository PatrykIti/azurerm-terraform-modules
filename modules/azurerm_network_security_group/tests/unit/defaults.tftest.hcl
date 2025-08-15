# Test default behavior of Network Security Group module

# Mock the Azure provider to avoid real API calls
mock_provider "azurerm" {
  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
    }
  }

  mock_resource "azurerm_network_security_rule" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg/securityRules/test-rule"
    }
  }

}

variables {
  name                = "test-nsg"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test that NSG is created with default settings
run "verify_nsg_creation" {
  command = plan

  assert {
    condition     = azurerm_network_security_group.network_security_group.name == "test-nsg"
    error_message = "NSG name should match the provided name"
  }

  assert {
    condition     = azurerm_network_security_group.network_security_group.resource_group_name == "test-rg"
    error_message = "NSG resource group should match the provided resource group"
  }

  assert {
    condition     = azurerm_network_security_group.network_security_group.location == "northeurope"
    error_message = "NSG location should match the provided location"
  }
}

# Test default tags are applied
run "verify_default_tags" {
  command = plan

  variables {
    name                = "test-nsg"
    resource_group_name = "test-rg"
    location            = "northeurope"
    tags = {
      Environment = "Test"
      Module      = "NetworkSecurityGroup"
    }
  }

  assert {
    condition     = azurerm_network_security_group.network_security_group.tags["Environment"] == "Test"
    error_message = "NSG should have the Environment tag"
  }

  assert {
    condition     = azurerm_network_security_group.network_security_group.tags["Module"] == "NetworkSecurityGroup"
    error_message = "NSG should have the Module tag"
  }
}

# Test with no security rules (empty list)
run "verify_no_security_rules" {
  command = plan

  variables {
    name                = "test-nsg"
    resource_group_name = "test-rg"
    location            = "northeurope"
    security_rules      = []
  }

  assert {
    condition     = length(azurerm_network_security_rule.security_rules) == 0
    error_message = "No security rules should be created when security_rules is empty"
  }
}


