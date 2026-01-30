terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "application_insights" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_application_insights?ref=APPINSv1.0.0"

  name                = var.application_insights_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id

  retention_in_days                     = 90
  sampling_percentage                   = 25
  daily_data_cap_in_gb                  = 5
  daily_data_cap_notifications_disabled = false
  disable_ip_masking                    = false

  monitoring = [
    {
      name                       = "diag"
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Complete"
  }
}
