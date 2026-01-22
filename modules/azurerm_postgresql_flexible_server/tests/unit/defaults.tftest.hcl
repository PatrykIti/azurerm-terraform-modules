# Defaults tests for PostgreSQL Flexible Server module

mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
      name                          = "pgfsunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      fqdn                          = "pgfsunit.postgres.database.azure.com"
      public_network_access_enabled = true
      backup_retention_days         = 7
      geo_redundant_backup_enabled  = false
      tags                          = {}
    }
  }

  mock_resource "azurerm_postgresql_flexible_server_configuration" {}
  mock_resource "azurerm_postgresql_flexible_server_firewall_rule" {}
  mock_resource "azurerm_postgresql_flexible_server_active_directory_administrator" {}
  mock_resource "azurerm_postgresql_flexible_server_virtual_endpoint" {}
  mock_resource "azurerm_postgresql_flexible_server_backup" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["PostgreSQLLogs"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                   = "pgfsunit"
  resource_group_name    = "test-rg"
  location               = "northeurope"
  sku_name               = "Standard_D2s_v3"
  postgresql_version     = "15"
  administrator_login    = "pgfsadmin"
  administrator_password = "Password1234"
}

run "verify_public_network_default" {
  command = plan

  assert {
    condition     = azurerm_postgresql_flexible_server.postgresql_flexible_server.public_network_access_enabled == true
    error_message = "public_network_access_enabled should default to true when no private networking is configured."
  }
}

run "verify_backup_defaults" {
  command = plan

  assert {
    condition     = azurerm_postgresql_flexible_server.postgresql_flexible_server.backup_retention_days == 7
    error_message = "backup_retention_days should default to 7."
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.postgresql_flexible_server.geo_redundant_backup_enabled == false
    error_message = "geo_redundant_backup_enabled should default to false."
  }
}

run "verify_tags_default" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}

run "verify_authentication_defaults" {
  command = plan

  assert {
    condition     = azurerm_postgresql_flexible_server.postgresql_flexible_server.authentication[0].password_auth_enabled == true
    error_message = "password authentication should be enabled by default."
  }
}
