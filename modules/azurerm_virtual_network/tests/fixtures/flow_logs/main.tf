# Flow Logs Virtual Network Example
# This example demonstrates a Virtual Network configuration with network flow logs enabled

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-flow-${var.random_suffix}"
  location = var.location
}

# Create Log Analytics Workspace for flow logs monitoring
resource "azurerm_log_analytics_workspace" "flow" {
  name                = "law-dpc-flow-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "FlowLogs"
  }
}

# Create Storage Account for flow logs
resource "azurerm_storage_account" "flow" {
  name                     = "stdpcflow${lower(var.random_suffix)}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security settings
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true # Required for flow logs
  shared_access_key_enabled       = true # Required for flow logs
  allow_nested_items_to_be_public = false

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "FlowLogs"
  }
}

# Network Watcher configuration is in network_watcher.tf
# It handles automatic detection of existing default Network Watcher

# Create Network Security Group for flow log testing
resource "azurerm_network_security_group" "test" {
  name                = "nsg-dpc-flow-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  # Allow HTTP for testing flow logs
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "FlowLogs"
  }
}

# Virtual Network configuration with flow logs focus
module "virtual_network" {
  source = "../../../"

  name                = "vnet-dpc-flow-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  # Network Flow Configuration
  flow_timeout_in_minutes = 10

  # Network Watcher Flow Log for monitoring
  flow_log = {
    network_watcher_name                = local.network_watcher_name
    network_watcher_resource_group_name = local.network_watcher_rg
    network_security_group_id           = azurerm_network_security_group.test.id
    storage_account_id                  = azurerm_storage_account.flow.id
    enabled                             = true
    version                             = 2
    retention_policy = {
      enabled = true
      days    = 7
    }
    traffic_analytics = {
      enabled               = true
      workspace_id          = azurerm_log_analytics_workspace.flow.workspace_id
      workspace_region      = azurerm_log_analytics_workspace.flow.location
      workspace_resource_id = azurerm_log_analytics_workspace.flow.id
      interval_in_minutes   = 10
    }
  }

  # Basic diagnostic settings
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.flow.id
    storage_account_id         = azurerm_storage_account.flow.id
    logs = {
      vm_protection_alerts = true
    }
    metrics = {
      all_metrics = true
    }
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "FlowLogs"
  }
}