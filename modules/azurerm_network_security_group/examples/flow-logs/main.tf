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

resource "azurerm_storage_account" "flow_logs" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

data "azurerm_network_watcher" "example" {
  name                = var.network_watcher_name
  resource_group_name = var.network_watcher_resource_group_name
}

module "network_security_group" {
  source = "../.."

  name                = var.nsg_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = [
    {
      name                       = "allow_https"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow HTTPS inbound"
    }
  ]

  flow_log = var.enable_flow_log ? {
    name                                = "nsg-flow-logs-example"
    storage_account_id                  = azurerm_storage_account.flow_logs.id
    network_watcher_name                = data.azurerm_network_watcher.example.name
    network_watcher_resource_group_name = data.azurerm_network_watcher.example.resource_group_name
    retention_policy = {
      enabled = true
      days    = 30
    }
    traffic_analytics = {
      enabled               = true
      workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
      workspace_region      = azurerm_log_analytics_workspace.example.location
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
      interval_in_minutes   = 10
    }
  } : null

  tags = {
    Environment = "Development"
    Example     = "FlowLogs"
  }
}
