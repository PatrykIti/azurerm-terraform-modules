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

resource "azurerm_storage_account" "diagnostics" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_eventhub_namespace" "example" {
  name                = var.eventhub_namespace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "example" {
  name              = var.eventhub_name
  namespace_id      = azurerm_eventhub_namespace.example.id
  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "example" {
  name                = "nsg-diagnostics"
  namespace_name      = azurerm_eventhub_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
  send                = true
  listen              = false
  manage              = false
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

  diagnostic_settings = [
    {
      name                           = "nsg-diagnostics"
      areas                          = ["event", "rule_counter", "metrics"]
      log_analytics_workspace_id     = azurerm_log_analytics_workspace.example.id
      log_analytics_destination_type = "Dedicated"
      storage_account_id             = azurerm_storage_account.diagnostics.id
      eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.example.id
      eventhub_name                  = azurerm_eventhub.example.name
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "DiagnosticSettings"
  }
}
