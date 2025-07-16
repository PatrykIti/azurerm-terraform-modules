provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-secure-example"
  location = "West Europe"
}

module "subnet" {
  source = "../../"

  name                = "subnetexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
