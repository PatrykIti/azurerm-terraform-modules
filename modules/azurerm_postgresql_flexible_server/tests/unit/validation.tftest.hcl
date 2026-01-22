# Validation tests for PostgreSQL Flexible Server module

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
  name                = "pgfsunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku_name            = "Standard_D2s_v3"
  postgresql_version             = "15"
  administrator_login = "pgfsadmin"
  administrator_password = "Password1234"
}

run "invalid_version" {
  command = plan

  variables {
    postgresql_version = "10"
  }

  expect_failures = [
    var.postgresql_version
  ]
}

run "invalid_backup_retention" {
  command = plan

  variables {
    backup = {
      retention_days = 3
    }
  }

  expect_failures = [
    var.backup
  ]
}

run "invalid_storage_tier" {
  command = plan

  variables {
    storage = {
      storage_tier = "P3"
    }
  }

  expect_failures = [
    var.storage
  ]
}

run "authentication_all_disabled" {
  command = plan

  variables {
    authentication = {
      active_directory_auth_enabled = false
      password_auth_enabled         = false
    }
  }

  expect_failures = [
    var.authentication
  ]
}

run "aad_auth_missing_tenant" {
  command = plan

  variables {
    authentication = {
      active_directory_auth_enabled = true
      password_auth_enabled         = true
    }
  }

  expect_failures = [
    var.authentication
  ]
}

run "invalid_high_availability_mode" {
  command = plan

  variables {
    high_availability = {
      mode = "Invalid"
    }
  }

  expect_failures = [
    var.high_availability
  ]
}

run "invalid_maintenance_window" {
  command = plan

  variables {
    maintenance_window = {
      day_of_week  = 9
      start_hour   = 25
      start_minute = 80
    }
  }

  expect_failures = [
    var.maintenance_window
  ]
}

run "invalid_firewall_ip" {
  command = plan

  variables {
    firewall_rules = [
      {
        name             = "bad-ip"
        start_ip_address = "not-an-ip"
        end_ip_address   = "not-an-ip"
      }
    ]
  }

  expect_failures = [
    var.firewall_rules
  ]
}

run "invalid_create_mode" {
  command = plan

  variables {
    create_mode = {
      mode = "Invalid"
    }
  }

  expect_failures = [
    var.create_mode
  ]
}

run "virtual_endpoints_missing_ids" {
  command = plan

  variables {
    virtual_endpoints = [
      {
        name = "missing-ids"
      }
    ]
  }

  expect_failures = [
    var.virtual_endpoints
  ]
}

run "diagnostic_settings_missing_destination" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name  = "missing-destination"
        areas = ["all"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_missing_eventhub_name" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "missing-eventhub-name"
        eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ns/authorizationRules/rule"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}
