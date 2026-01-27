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
  server = {
    sku_name           = "GP_Standard_D2s_v3"
    postgresql_version = "15"
  }
  authentication = {
    administrator = {
      login    = "pgfsadmin"
      password = "Password1234"
    }
  }
}

run "invalid_version" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "10"
    }
  }

  expect_failures = [
    var.server
  ]
}

run "invalid_backup_retention" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      backup = {
        retention_days = 3
      }
    }
  }

  expect_failures = [
    var.server
  ]
}

run "invalid_storage_tier" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      storage = {
        storage_tier = "P3"
      }
    }
  }

  expect_failures = [
    var.server
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

run "password_auth_missing_passwords" {
  command = plan

  variables {
    authentication = {
      password_auth_enabled = true
      administrator = {
        login = "pgfsadmin"
      }
    }
  }

  expect_failures = [
    var.authentication
  ]
}

run "password_wo_only" {
  command = plan

  variables {
    authentication = {
      password_auth_enabled = true
      administrator = {
        login               = "pgfsadmin"
        password_wo         = "Password1234"
        password_wo_version = 1
      }
    }
  }
}

run "password_wo_missing_version" {
  command = plan

  variables {
    authentication = {
      password_auth_enabled = true
      administrator = {
        login       = "pgfsadmin"
        password_wo = "Password1234"
      }
    }
  }

  expect_failures = [
    var.authentication
  ]
}

run "password_wo_version_requires_password_wo" {
  command = plan

  variables {
    authentication = {
      password_auth_enabled = true
      administrator = {
        login               = "pgfsadmin"
        password_wo_version = 1
      }
    }
  }

  expect_failures = [
    var.authentication
  ]
}

run "password_and_password_wo_conflict" {
  command = plan

  variables {
    authentication = {
      password_auth_enabled = true
      administrator = {
        login       = "pgfsadmin"
        password    = "Password1234"
        password_wo = "Password1234"
      }
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
      administrator = {
        login    = "pgfsadmin"
        password = "Password1234"
      }
      active_directory_administrator = {
        principal_name = "admin@example.com"
        object_id      = "00000000-0000-0000-0000-000000000000"
        principal_type = "User"
      }
    }
  }

  expect_failures = [
    var.authentication
  ]
}

run "invalid_high_availability_mode" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      high_availability = {
        mode = "Invalid"
      }
    }
  }

  expect_failures = [
    var.server
  ]
}

run "invalid_maintenance_window" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      maintenance_window = {
        day_of_week  = 9
        start_hour   = 25
        start_minute = 80
      }
    }
  }

  expect_failures = [
    var.server
  ]
}

run "invalid_replication_role" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      replication_role   = "Primary"
    }
  }

  expect_failures = [
    var.server
  ]
}

run "replication_role_requires_update_mode" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      replication_role   = "None"
    }
  }

  expect_failures = [
    var.server
  ]
}

run "invalid_firewall_ip" {
  command = plan

  variables {
    network = {
      firewall_rules = [
        {
          name             = "bad-ip"
          start_ip_address = "not-an-ip"
          end_ip_address   = "not-an-ip"
        }
      ]
    }
  }

  expect_failures = [
    var.network
  ]
}

run "invalid_create_mode" {
  command = plan

  variables {
    server = {
      sku_name           = "GP_Standard_D2s_v3"
      postgresql_version = "15"
      create_mode = {
        mode = "Invalid"
      }
    }
  }

  expect_failures = [
    var.server
  ]
}

run "virtual_endpoints_missing_ids" {
  command = plan

  variables {
    features = {
      virtual_endpoints = [
        {
          name = "missing-ids"
        }
      ]
    }
  }

  expect_failures = [
    var.features
  ]
}

run "diagnostic_settings_missing_destination" {
  command = plan

  variables {
    monitoring = [
      {
        name           = "missing-destination"
        log_categories = ["PostgreSQLLogs"]
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}

run "diagnostic_settings_missing_eventhub_name" {
  command = plan

  variables {
    monitoring = [
      {
        name                           = "missing-eventhub-name"
        metric_categories              = ["AllMetrics"]
        eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ns/authorizationRules/rule"
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}
