# Defaults tests for App Service Plan module

mock_provider "azurerm" {
  mock_resource "azurerm_service_plan" {
    defaults = {
      id                              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/aspunit"
      name                            = "aspunit"
      location                        = "northeurope"
      resource_group_name             = "test-rg"
      kind                            = "app"
      reserved                        = false
      worker_count                    = null
      premium_plan_auto_scale_enabled = false
      per_site_scaling_enabled        = false
      zone_balancing_enabled          = false
      tags                            = {}
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "aspunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan = {
    os_type  = "Windows"
    sku_name = "B1"
  }
}

run "verify_default_scaling_flags" {
  command = plan

  assert {
    condition     = azurerm_service_plan.service_plan.premium_plan_auto_scale_enabled == false
    error_message = "premium_plan_auto_scale_enabled should default to false."
  }

  assert {
    condition     = azurerm_service_plan.service_plan.per_site_scaling_enabled == false
    error_message = "per_site_scaling_enabled should default to false."
  }

  assert {
    condition     = azurerm_service_plan.service_plan.zone_balancing_enabled == false
    error_message = "zone_balancing_enabled should default to false."
  }
}

run "verify_worker_count_default" {
  command = plan

  assert {
    condition     = var.service_plan.worker_count == null
    error_message = "worker_count should default to null."
  }
}

run "verify_tags_default" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}
