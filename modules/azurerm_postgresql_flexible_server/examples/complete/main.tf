provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-postgresql_flexible_server-complete-example"
  location = "West Europe"
}

module "postgresql_flexible_server" {
  source = "../../"

  name                = "postgresqlflexibleserverexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
