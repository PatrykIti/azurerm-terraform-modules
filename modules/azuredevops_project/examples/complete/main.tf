provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-azuredevops_project-complete-example"
  location = "West Europe"
}

module "azuredevops_project" {
  source = "../../"

  name                = "azuredevopsprojectexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
