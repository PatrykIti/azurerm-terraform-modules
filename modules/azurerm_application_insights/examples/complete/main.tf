provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-application_insights-complete-example"
  location = "West Europe"
}

module "application_insights" {
  source = "../../"

  name                = "applicationinsightsexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
