provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

module "ai_services" {
  source = "../../"

  name                = var.ai_services_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = var.sku_name

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
