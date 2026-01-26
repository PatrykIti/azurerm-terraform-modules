# Validation tests for PostgreSQL Flexible Server Database module

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

run "missing_server_id" {
  command = plan

  variables {
    server_id = ""
  }

  expect_failures = [
    var.server_id
  ]
}

run "empty_charset" {
  command = plan

  variables {
    name    = "appdbunit"
    charset = ""
  }

  expect_failures = [
    var.charset
  ]
}

run "empty_collation" {
  command = plan

  variables {
    name      = "appdbunit"
    collation = ""
  }

  expect_failures = [
    var.collation
  ]
}
