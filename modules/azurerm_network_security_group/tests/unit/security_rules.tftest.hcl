# Test various security rule configurations for Network Security Group module

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

# Test single inbound rule
run "single_inbound_rule" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "allow-ssh"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.0.0/24"
        destination_address_prefix = "*"
        description                = "Allow SSH from internal network"
      }
    ]
  }

  assert {
    condition     = length(azurerm_network_security_rule.security_rules) == 1
    error_message = "Should create exactly one security rule"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-ssh"].name == "allow-ssh"
    error_message = "Security rule name should match"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-ssh"].priority == 100
    error_message = "Security rule priority should be 100"
  }
}

# Test multiple port ranges
run "multiple_port_ranges" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "allow-web"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80", "443", "8080-8090"]
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow web traffic"
      }
    ]
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-web"].destination_port_ranges == toset(["80", "443", "8080-8090"])
    error_message = "Should support multiple destination port ranges"
  }
}

# Test multiple address prefixes
run "multiple_address_prefixes" {
  command = plan

  variables {
    security_rules = [
      {
        name                         = "allow-management"
        priority                     = 120
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "3389"
        source_address_prefixes      = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
        destination_address_prefix   = "*"
        description                  = "Allow RDP from management subnets"
      }
    ]
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-management"].source_address_prefixes == toset(["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"])
    error_message = "Should support multiple source address prefixes"
  }
}

# Test service tags
run "service_tags" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "allow-azure-services"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "VirtualNetwork"
        description                = "Allow Azure Load Balancer"
      }
    ]
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-azure-services"].source_address_prefix == "AzureLoadBalancer"
    error_message = "Should support Azure service tags"
  }
}

# Test outbound rules
run "outbound_rules" {
  command = plan

  variables {
    security_rules = [
      {
        name                         = "allow-internet-https"
        priority                     = 200
        direction                    = "Outbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "443"
        source_address_prefix        = "VirtualNetwork"
        destination_address_prefix   = "Internet"
        description                  = "Allow HTTPS to Internet"
      },
      {
        name                         = "deny-all-outbound"
        priority                     = 4096
        direction                    = "Outbound"
        access                       = "Deny"
        protocol                     = "*"
        source_port_range            = "*"
        destination_port_range       = "*"
        source_address_prefix        = "*"
        destination_address_prefix   = "*"
        description                  = "Deny all other outbound"
      }
    ]
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-internet-https"].direction == "Outbound"
    error_message = "Should create outbound rules"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["deny-all-outbound"].access == "Deny"
    error_message = "Should support deny rules"
  }
}

# Test all protocols
run "all_protocols" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "allow-tcp"
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
        name                       = "allow-udp"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Udp"
        source_port_range          = "*"
        destination_port_range     = "53"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-icmp"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-all"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.0.0.0/8"
        destination_address_prefix = "*"
      }
    ]
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-tcp"].protocol == "Tcp"
    error_message = "Should support TCP protocol"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-udp"].protocol == "Udp"
    error_message = "Should support UDP protocol"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-icmp"].protocol == "Icmp"
    error_message = "Should support ICMP protocol"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["allow-all"].protocol == "*"
    error_message = "Should support all protocols with *"
  }
}

# Test complex rule set (simulating zero-trust)
run "zero_trust_rules" {
  command = plan

  variables {
    security_rules = [
      {
        name                       = "allow-specific-https"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "203.0.113.0/24"
        destination_address_prefix = "10.1.0.0/24"
        description                = "Allow HTTPS from specific external network"
      },
      {
        name                       = "allow-internal-communication"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.0.0.0/8"
        destination_address_prefix = "10.0.0.0/8"
        description                = "Allow all internal communication"
      },
      {
        name                       = "deny-all-inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Deny all other inbound traffic"
      }
    ]
  }

  assert {
    condition     = length(azurerm_network_security_rule.security_rules) == 3
    error_message = "Should create all three rules for zero-trust configuration"
  }

  assert {
    condition     = azurerm_network_security_rule.security_rules["deny-all-inbound"].priority == 4096
    error_message = "Deny all rule should have lowest priority (4096)"
  }
}