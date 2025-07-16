provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-basic-example"
  location = "West Europe"
}

module "subnet" {
  source = "../../"

  name                = "subnetexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
