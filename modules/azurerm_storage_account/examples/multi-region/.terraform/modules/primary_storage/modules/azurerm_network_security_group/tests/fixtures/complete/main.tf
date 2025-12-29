provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-cmp-${var.random_suffix}"
  location = var.location
}


module "network_security_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  name                = "nsg-cmp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = [
    {
      name                       = "allow_ssh_inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/16"
      destination_address_prefix = "*"
      description                = "Allow SSH from internal network"
    },
    {
      name                       = "deny_rdp_outbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      description                = "Deny RDP to the Internet"
    }
  ]


  tags = {
    Environment = "Test"
    Scenario    = "Complete"
  }
}
