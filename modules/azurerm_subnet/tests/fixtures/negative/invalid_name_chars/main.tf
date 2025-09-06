provider "azurerm" {
  features {}
  subscription_id            = "00000000-0000-0000-0000-000000000000"
  skip_provider_registration = true
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
}

module "subnet" {
  source = "../../../../"

  name                 = "subnet_test@123"  # Invalid characters - should fail validation
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}