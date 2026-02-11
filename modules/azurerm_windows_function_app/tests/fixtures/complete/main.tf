provider "azurerm" {
  features {}
}

locals {
  suffix               = substr(var.random_suffix, 0, 8)
  resource_group_name  = "rg-wfunc-complete-${local.suffix}"
  storage_account_name = "stwfcomp${local.suffix}"
  service_plan_name    = "asp-wfunc-complete-${local.suffix}"
  function_app_name    = "wfunccomp${local.suffix}"
  law_name             = "law-wfunc-${local.suffix}"
  appi_name            = "appi-wfunc-${local.suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = local.service_plan_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Windows"
  sku_name            = "EP1"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = local.law_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = local.appi_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

module "windows_function_app" {
  source = "../../../"

  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.example.id

  storage_configuration = {
    account_name       = azurerm_storage_account.example.name
    account_access_key = azurerm_storage_account.example.primary_access_key
  }

  application_configuration = {
    functions_extension_version            = "~4"
    application_insights_connection_string = azurerm_application_insights.example.connection_string
    app_settings = {
      WEBSITE_RUN_FROM_PACKAGE = "1"
      EXAMPLE_SETTING          = "complete"
    }
    connection_strings = [
      {
        name  = "storage"
        type  = "Custom"
        value = azurerm_storage_account.example.primary_connection_string
      }
    ]
  }

  access_configuration = {
    public_network_access_enabled = true
  }

  site_config = {
    always_on                         = true
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    health_check_path                 = "/api/health"
    health_check_eviction_time_in_min = 2
    application_stack = {
      node_version = "~18"
    }
  }

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_category_groups        = ["allLogs"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  slots = [
    {
      name = "staging"
      app_settings = {
        SLOT_SETTING = "true"
      }
      https_only = true
      site_config = {
        application_stack = {
          node_version = "~18"
        }
      }
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "Complete"
    CostCenter  = "Engineering"
    Owner       = "terratest"
  }
}
