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
  server = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
  }
  database = {
    name = "appdbunit"
  }
}

run "verify_optional_defaults" {
  command = plan

  assert {
    condition     = var.database.charset == null
    error_message = "database.charset should default to null when not set."
  }

  assert {
    condition     = var.database.collation == null
    error_message = "database.collation should default to null when not set."
  }
}
