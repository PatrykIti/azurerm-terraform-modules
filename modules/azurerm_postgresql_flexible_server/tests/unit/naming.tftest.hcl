# Naming validation tests for PostgreSQL Flexible Server module

mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
      name = "pgfsunit"
    }
  }

  mock_resource "azurerm_postgresql_flexible_server_configuration" {}
  mock_resource "azurerm_postgresql_flexible_server_firewall_rule" {}
  mock_resource "azurerm_postgresql_flexible_server_active_directory_administrator" {}
  mock_resource "azurerm_postgresql_flexible_server_virtual_endpoint" {}
  mock_resource "azurerm_postgresql_flexible_server_backup" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  resource_group_name    = "test-rg"
  location               = "northeurope"
  sku_name               = "GP_Standard_D2s_v3"
  postgresql_version     = "15"
  administrator_login    = "pgfsadmin"
  administrator_password = "Password1234"
}

run "invalid_name_uppercase" {
  command = plan

  variables {
    name = "INVALID-NAME"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_short" {
  command = plan

  variables {
    name = "ab"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_trailing_hyphen" {
  command = plan

  variables {
    name = "pgfs-"
  }

  expect_failures = [
    var.name
  ]
}
