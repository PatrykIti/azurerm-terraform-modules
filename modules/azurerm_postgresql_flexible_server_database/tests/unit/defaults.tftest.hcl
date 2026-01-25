# Defaults tests for PostgreSQL Flexible Server Database module

mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server_database" {
    defaults = {
      id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit/databases/appdbunit"
      name       = "appdbunit"
      server_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
    }
  }
}

variables {
  server_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
  name      = "appdbunit"
}

run "verify_optional_defaults" {
  command = plan

  assert {
    condition     = var.charset == null
    error_message = "charset should default to null when not set."
  }

  assert {
    condition     = var.collation == null
    error_message = "collation should default to null when not set."
  }
}
