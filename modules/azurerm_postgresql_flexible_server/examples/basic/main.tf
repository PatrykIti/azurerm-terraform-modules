provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-postgresql_flexible_server-basic-example"
  location = "West Europe"
}

module "postgresql_flexible_server" {
  source = "../../"

  name                = "postgresqlflexibleserverexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
