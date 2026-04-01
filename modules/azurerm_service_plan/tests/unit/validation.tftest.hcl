# Validation tests for App Service Plan module

mock_provider "azurerm" {
  mock_resource "azurerm_service_plan" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/aspunit"
      name = "aspunit"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "aspunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan = {
    os_type  = "Linux"
    sku_name = "P1v3"
  }
}

run "invalid_os_type" {
  command = plan

  variables {
    service_plan = {
      os_type  = "MacOS"
      sku_name = "P1v3"
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "invalid_sku" {
  command = plan

  variables {
    service_plan = {
      os_type  = "Linux"
      sku_name = "NotARealSku"
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "premium_autoscale_requires_premium_sku" {
  command = plan

  variables {
    service_plan = {
      os_type                         = "Windows"
      sku_name                        = "B1"
      premium_plan_auto_scale_enabled = true
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "maximum_elastic_workers_requires_supported_plan" {
  command = plan

  variables {
    service_plan = {
      os_type                      = "Windows"
      sku_name                     = "S1"
      maximum_elastic_worker_count = 5
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "zone_balancing_requires_supported_sku" {
  command = plan

  variables {
    service_plan = {
      os_type                = "Windows"
      sku_name               = "B1"
      worker_count           = 2
      zone_balancing_enabled = true
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "zone_balancing_requires_multiple_workers" {
  command = plan

  variables {
    service_plan = {
      os_type                = "Linux"
      sku_name               = "P1v3"
      worker_count           = 1
      zone_balancing_enabled = true
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "ase_requires_isolated_sku" {
  command = plan

  variables {
    service_plan = {
      os_type                    = "Linux"
      sku_name                   = "P1v3"
      app_service_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/hostingEnvironments/example-ase"
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "diagnostic_settings_invalid_metric_category" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "asp-diag"
        metric_categories          = ["CpuPercentage"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_logs_not_supported" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "asp-diag"
        log_categories             = ["AppServiceConsoleLogs"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "valid_elastic_premium_configuration" {
  command = plan

  variables {
    service_plan = {
      os_type                      = "Linux"
      sku_name                     = "EP1"
      maximum_elastic_worker_count = 20
    }
  }
}

run "elastic_premium_rejects_premium_autoscale_flag" {
  command = plan

  variables {
    service_plan = {
      os_type                         = "Linux"
      sku_name                        = "EP1"
      premium_plan_auto_scale_enabled = true
      maximum_elastic_worker_count    = 20
    }
  }

  expect_failures = [
    var.service_plan
  ]
}

run "valid_premium_autoscale_configuration" {
  command = plan

  variables {
    service_plan = {
      os_type                         = "Linux"
      sku_name                        = "P1v3"
      premium_plan_auto_scale_enabled = true
      maximum_elastic_worker_count    = 5
    }
  }
}
