provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-azuredevops_project-basic-example"
  location = "West Europe"
}

module "azuredevops_project" {
  source = "../../"

  name                = "azuredevopsprojectexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
