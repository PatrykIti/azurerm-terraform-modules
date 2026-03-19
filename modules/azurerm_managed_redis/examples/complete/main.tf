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
  name     = "rg-managed-redis-complete-example"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-managed-redis-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "managed_redis" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_managed_redis?ref=AMRv1.0.0"

  name                = "managed-redis-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  managed_redis = {
    sku_name                  = "Balanced_B5"
    high_availability_enabled = true
    public_network_access     = "Enabled"
  }

  default_database = {
    access_keys_authentication_enabled = true
    client_protocol                    = "Encrypted"
    clustering_policy                  = "EnterpriseCluster"
    eviction_policy                    = "NoEviction"
    geo_replication_group_name         = "managed-redis-complete-group"
    modules = [
      {
        name = "RediSearch"
      },
      {
        name = "RedisJSON"
      }
    ]
  }

  monitoring = [
    {
      name                       = "managed-redis-diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_categories             = ["ConnectionEvents"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
