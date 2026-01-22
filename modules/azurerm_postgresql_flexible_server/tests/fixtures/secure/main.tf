provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-postgresql_flexible_server-secure-example"
  location = "West Europe"
}

module "postgresql_flexible_server" {
  source = "../../"

  name                = "postgresqlflexibleserverexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
