provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-application_insights-secure-example"
  location = "West Europe"
}

module "application_insights" {
  source = "../../"

  name                = "applicationinsightsexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
