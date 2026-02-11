provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-linux-function-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stlfasecure${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "example" {
  name                = "plan-linux-function-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-linux-function-secure-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "appi-linux-function-secure-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

module "linux_function_app" {
  source = "../../../"

  name                = "funcsecure${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan_id = azurerm_service_plan.example.id

  storage_configuration = {
    account_name          = azurerm_storage_account.example.name
    uses_managed_identity = true
  }

  identity = {
    type = "SystemAssigned"
  }

  application_configuration = {
    application_insights_connection_string = azurerm_application_insights.example.connection_string
  }

  access_configuration = {
    https_only                    = true
    public_network_access_enabled = false
  }

  site_configuration = {
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"
    application_stack = {
      node_version = "20"
    }
    ip_restriction = [
      {
        name       = "corp-network"
        ip_address = "10.0.0.0/24"
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
    Environment = "Production"
    Example     = "Secure"
  }
}
