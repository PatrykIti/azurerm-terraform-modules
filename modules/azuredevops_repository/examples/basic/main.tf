provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-azuredevops_repository-basic-example"
  location = "West Europe"
}

module "azuredevops_repository" {
  source = "../../"

  name                = "azuredevopsrepositoryexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
