# Flow Logs Virtual Network Example
# This example demonstrates a Virtual Network configuration with network flow logs enabled

terraform {
  required_version = ">= 1.12.2"
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

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "FlowLogs"
  }
}

# Network Watcher Flow Log - now managed as separate resource for monitoring
resource "azurerm_network_watcher_flow_log" "test" {
  network_watcher_name = local.network_watcher_name
  resource_group_name  = local.network_watcher_rg
  name                 = "${module.virtual_network.name}-flowlog"
  target_resource_id   = azurerm_network_security_group.test.id
  storage_account_id   = azurerm_storage_account.flow.id
  enabled              = true
  version              = 2

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.flow.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.flow.location
    workspace_resource_id = azurerm_log_analytics_workspace.flow.id
    interval_in_minutes   = 10
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "FlowLogs"
    Purpose     = "Flow Log Monitoring"
  }

  depends_on = [module.virtual_network]
}

# Diagnostic Settings - now managed as separate resource
resource "azurerm_monitor_diagnostic_setting" "test" {
  name                       = "${module.virtual_network.name}-diag"
  target_resource_id         = module.virtual_network.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.flow.id
  storage_account_id         = azurerm_storage_account.flow.id

  # Virtual Network Logs
  enabled_log {
    category = "VMProtectionAlerts"
  }

  # Virtual Network Metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [module.virtual_network]
}