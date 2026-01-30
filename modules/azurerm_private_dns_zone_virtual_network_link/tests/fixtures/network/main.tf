# Network integration test fixture
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-private_dns_zone_virtual_network_link-network-test"
  location = "West Europe"
}

# Test with network rules
module "private_dns_zone_virtual_network_link" {
  source = "../../../"

  name                = "privatednszonevirtualnetworklinknetworktest"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
    bypass         = ["AzureServices"]
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
