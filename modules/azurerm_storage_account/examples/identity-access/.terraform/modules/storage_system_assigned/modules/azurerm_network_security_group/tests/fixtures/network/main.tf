provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-net-${var.random_suffix}"
  location = var.location
}

module "network_security_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.1"

  name                = "nsg-net-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = [
    {
      name                       = "allow_multiple_ports_and_sources"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["80", "8080", "443"]
      source_address_prefixes    = ["192.168.1.0/24", "10.10.0.0/16"]
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow web traffic from multiple sources"
    }
  ]

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
