provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-azuredevops_identity-basic-example"
  location = "West Europe"
}

module "azuredevops_identity" {
  source = "../../"

  name                = "azuredevopsidentityexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
