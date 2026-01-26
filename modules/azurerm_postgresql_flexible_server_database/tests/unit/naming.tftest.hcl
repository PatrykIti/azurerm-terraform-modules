# Naming validation tests for PostgreSQL Flexible Server Database module

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
}

run "invalid_name_uppercase" {
  command = plan

  variables {
    name = "INVALID_NAME"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_invalid_char" {
  command = plan

  variables {
    name = "bad.name"
  }

  expect_failures = [
    var.name
  ]
}
