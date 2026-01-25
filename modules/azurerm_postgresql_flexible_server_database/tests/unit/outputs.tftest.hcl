# Output tests for PostgreSQL Flexible Server Database module

mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server_database" {
    defaults = {
      id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit/databases/appdbunit"
      name      = "appdbunit"
      server_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }
}

variables {
  server_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
  name      = "appdbunit"
  charset   = "UTF8"
  collation = "en_US.utf8"
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit/databases/appdbunit"
    error_message = "Output 'id' should return the database ID."
  }

  assert {
    condition     = output.name == "appdbunit"
    error_message = "Output 'name' should return the database name."
  }

  assert {
    condition     = output.server_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
    error_message = "Output 'server_id' should return the server ID."
  }

  assert {
    condition     = output.charset == "UTF8"
    error_message = "Output 'charset' should return the database charset."
  }

  assert {
    condition     = output.collation == "en_US.utf8"
    error_message = "Output 'collation' should return the database collation."
  }
}
