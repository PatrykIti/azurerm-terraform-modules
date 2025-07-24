# Test variable validation with expected errors for Network Security Group module

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
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test NSG name too short
run "invalid_nsg_name_too_short" {
  command = plan

  variables {
    name = "" # Empty name
  }

  expect_failures = [
    var.name,
  ]
}

# Test NSG name too long
run "invalid_nsg_name_too_long" {
  command = plan

  variables {
    name = "this-is-a-very-long-network-security-group-name-that-exceeds-the-maximum-allowed-length-limit" # More than 80 characters
  }

  expect_failures = [
    var.name,
  ]
}

# Test NSG name with invalid characters
run "invalid_nsg_name_invalid_chars" {
  command = plan

  variables {
    name = "test nsg with spaces" # Contains spaces
  }

  expect_failures = [
    var.name,
  ]
}

# Test NSG name starting with invalid character
run "invalid_nsg_name_start_char" {
  command = plan

  variables {
    name = "-test-nsg" # Starts with hyphen
  }

  expect_failures = [
    var.name,
  ]
}

# Test NSG name ending with invalid character
run "invalid_nsg_name_end_char" {
  command = plan

  variables {
    name = "test-nsg-" # Ends with hyphen
  }

  expect_failures = [
    var.name,
  ]
}

# Test invalid security rule direction
run "invalid_security_rule_direction" {
  command = plan

  variables {
    name = "test-nsg"
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 100
        direction                  = "Both" # Invalid direction
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules,
  ]
}

# Test invalid security rule access
run "invalid_security_rule_access" {
  command = plan

  variables {
    name = "test-nsg"
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Block" # Invalid access (should be Allow or Deny)
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules,
  ]
}

# Test invalid security rule protocol
run "invalid_security_rule_protocol" {
  command = plan

  variables {
    name = "test-nsg"
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "HTTP" # Invalid protocol
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules,
  ]
}

# Test invalid security rule priority (too low)
run "invalid_security_rule_priority_too_low" {
  command = plan

  variables {
    name = "test-nsg"
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 99 # Below minimum (100)
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules,
  ]
}

# Test invalid security rule priority (too high)
run "invalid_security_rule_priority_too_high" {
  command = plan

  variables {
    name = "test-nsg"
    security_rules = [
      {
        name                       = "invalid-rule"
        priority                   = 4097 # Above maximum (4096)
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules,
  ]
}

# Test duplicate security rule priorities
run "invalid_duplicate_priorities" {
  command = plan

  variables {
    name = "test-nsg"
    security_rules = [
      {
        name                       = "rule1"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "rule2"
        priority                   = 100 # Duplicate priority
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  expect_failures = [
    var.security_rules,
  ]
}

# Test valid configuration to ensure module works
run "valid_configuration" {
  command = plan

  variables {
    name = "test-nsg-valid"
    security_rules = [
      {
        name                       = "allow-http"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow HTTP"
      }
    ]
  }

  # This should succeed
  assert {
    condition     = azurerm_network_security_group.network_security_group.name == "test-nsg-valid"
    error_message = "Valid configuration should work"
  }
}