terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-cmp-${var.random_suffix}"
  location = var.location
}

# Virtual network for network rules testing
resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-cmp-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "subnet-storage"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Log Analytics workspace for diagnostics
resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-dpc-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.3"

  name                     = "dpccmp${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    shared_access_key_enabled       = true # Required for Terraform to manage
  }

  # Encryption configuration
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
  }

  # Blob properties
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy = {
      enabled = true
      days    = 7
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 7
    }

    restore_policy = {
      enabled = true
      days    = 6
    }
  }

  # Containers
  containers = [
    {
      name                  = "data"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
    },
    {
      name                  = "backups"
      container_access_type = "private"
    }
  ]

  # Network rules
  network_rules = {
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [azurerm_subnet.test.id]
    bypass                     = ["AzureServices"]
  }


  # Tags
  tags = {
    Environment = "Test"
    TestType    = "Complete"
    CostCenter  = "Engineering"
    Owner       = "terratest"
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "primary_blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}

output "container_names" {
  value = [for k, v in module.storage_account.containers : v.name]
}