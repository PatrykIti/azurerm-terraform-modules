provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-application_insights-basic-example"
  location = "West Europe"
}

module "application_insights" {
  source = "../../"

  name                = "applicationinsightsexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
