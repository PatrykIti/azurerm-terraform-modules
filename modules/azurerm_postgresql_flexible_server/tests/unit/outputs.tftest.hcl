# Output tests for PostgreSQL Flexible Server module

mock_provider "azurerm" {
  mock_resource "azurerm_postgresql_flexible_server" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
      name                          = "pgfsunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      fqdn                          = "pgfsunit.postgres.database.azure.com"
      public_network_access_enabled = true
      tags = {
        Environment = "Test"
        Module      = "Pgfs"
      }
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
  name                   = "pgfsunit"
  resource_group_name    = "test-rg"
  location               = "northeurope"
  sku_name               = "GP_Standard_D2s_v3"
  postgresql_version     = "15"
  administrator_login    = "pgfsadmin"
  administrator_password = "Password1234"
  tags = {
    Environment = "Test"
    Module      = "Pgfs"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfsunit"
    error_message = "Output 'id' should return the server ID."
  }

  assert {
    condition     = output.name == "pgfsunit"
    error_message = "Output 'name' should return the server name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the server location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.fqdn == "pgfsunit.postgres.database.azure.com"
    error_message = "Output 'fqdn' should return the server FQDN."
  }
}

run "verify_empty_subresources" {
  command = plan

  assert {
    condition     = length(output.configurations) == 0
    error_message = "configurations output should be empty when not configured."
  }

  assert {
    condition     = length(output.firewall_rules) == 0
    error_message = "firewall_rules output should be empty when not configured."
  }

  assert {
    condition     = length(output.virtual_endpoints) == 0
    error_message = "virtual_endpoints output should be empty when not configured."
  }

  assert {
    condition     = length(output.backups) == 0
    error_message = "backups output should be empty when not configured."
  }
}

run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include Environment tag."
  }

  assert {
    condition     = output.tags["Module"] == "Pgfs"
    error_message = "Output 'tags' should include Module tag."
  }
}
