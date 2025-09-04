provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-basic-example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}

module "subnet" {
  source = "../../"

  name                 = "subnetexample001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}
