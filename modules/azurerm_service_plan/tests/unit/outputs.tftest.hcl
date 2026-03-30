# Output tests for App Service Plan module

mock_provider "azurerm" {
  mock_resource "azurerm_service_plan" {
    defaults = {
      id                              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/aspunit"
      name                            = "aspunit"
      location                        = "northeurope"
      resource_group_name             = "test-rg"
      kind                            = "linux"
      reserved                        = true
      worker_count                    = 2
      maximum_elastic_worker_count    = 10
      premium_plan_auto_scale_enabled = false
      per_site_scaling_enabled        = true
      zone_balancing_enabled          = true
      tags = {
        Environment = "Test"
        Module      = "Asp"
      }
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "aspunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan = {
    os_type                  = "Linux"
    sku_name                 = "P1v3"
    worker_count             = 2
    per_site_scaling_enabled = true
    zone_balancing_enabled   = true
  }
  tags = {
    Environment = "Test"
    Module      = "Asp"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/aspunit"
    error_message = "Output 'id' should return the plan ID."
  }

  assert {
    condition     = output.name == "aspunit"
    error_message = "Output 'name' should return the plan name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the plan location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.kind == "linux"
    error_message = "Output 'kind' should return the plan kind."
  }
}

run "verify_scaling_outputs" {
  command = plan

  assert {
    condition     = output.worker_count == 2
    error_message = "worker_count output should return the configured worker count."
  }

  assert {
    condition     = output.per_site_scaling_enabled == true
    error_message = "per_site_scaling_enabled output should return true."
  }

  assert {
    condition     = output.zone_balancing_enabled == true
    error_message = "zone_balancing_enabled output should return true."
  }
}

run "verify_empty_diagnostic_settings" {
  command = plan

  assert {
    condition     = length(output.diagnostic_settings) == 0
    error_message = "diagnostic_settings output should be empty when not configured."
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "diagnostic_settings_skipped output should be empty when not configured."
  }
}

run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include Environment tag."
  }

  assert {
    condition     = output.tags["Module"] == "Asp"
    error_message = "Output 'tags' should include Module tag."
  }
}
