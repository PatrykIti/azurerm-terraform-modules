# Negative test cases - should fail validation
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-subnet-negative-test"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-subnet-negative-test"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}

# This should fail due to invalid address prefix
module "subnet" {
  source = "../../../"

  name                 = "subnettest"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["invalid-cidr"] # Should fail validation
}
