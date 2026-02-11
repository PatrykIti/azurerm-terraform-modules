provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-wfunc-secure"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "stwfuncsecure001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "asp-wfunc-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Windows"
  sku_name            = "EP1"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-wfunc-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-wfunc-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "appi-wfunc-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

module "windows_function_app" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_windows_function_app?ref=WFUNCv1.0.0"

  name                = "wfuncsecure001"
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
  }

  access_configuration = {
    public_network_access_enabled = false
    https_only                    = true
    client_certificate_enabled    = true
    client_certificate_mode       = "Required"
  }

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  site_config = {
    minimum_tls_version           = "1.2"
    scm_minimum_tls_version       = "1.2"
    ftps_state                    = "Disabled"
    http2_enabled                 = true
    ip_restriction_default_action = "Deny"
    ip_restriction = [
      {
        name       = "office"
        priority   = 100
        action     = "Allow"
        ip_address = "203.0.113.0/24"
      }
    ]
    application_stack = {
      dotnet_version = "v8.0"
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

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
