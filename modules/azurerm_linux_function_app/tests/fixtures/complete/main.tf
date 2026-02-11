provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-linux-function-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stlfacomplete${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "example" {
  name                = "plan-linux-function-complete-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-linux-function-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "appi-linux-function-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

module "linux_function_app" {
  source = "../../../"

  name                = "funccomplete${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan_id = azurerm_service_plan.example.id

  storage_configuration = {
    account_name       = azurerm_storage_account.example.name
    account_access_key = azurerm_storage_account.example.primary_access_key
  }

  application_configuration = {
    application_insights_connection_string = azurerm_application_insights.example.connection_string
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "node"
      WEBSITE_RUN_FROM_PACKAGE = "1"
    }
    connection_strings = [
      {
        name  = "example-db"
        type  = "SQLAzure"
        value = "Server=tcp:example.database.windows.net,1433;Database=example;User ID=example;Password=example;"
      }
    ]
  }

  auth_settings = {
    enabled                       = true
    default_provider              = "AzureActiveDirectory"
    unauthenticated_client_action = "RedirectToLoginPage"
    active_directory = {
      client_id     = var.aad_client_id
      client_secret = var.aad_client_secret
    }
  }

  site_configuration = {
    always_on                     = true
    ftps_state                    = "FtpsOnly"
    http2_enabled                 = true
    minimum_tls_version           = "1.2"
    scm_minimum_tls_version       = "1.2"
    health_check_path             = "/api/health"
    ip_restriction_default_action = "Allow"
    application_stack = {
      node_version = "20"
    }
    cors = {
      allowed_origins = ["https://example.com"]
    }
    ip_restriction = [
      {
        name       = "allow-all"
        ip_address = "0.0.0.0/0"
        action     = "Allow"
        priority   = 100
      }
    ]
  }

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_category_groups        = ["allLogs"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
