provider "azurerm" {
  features {}
}

locals {
  storage_account_name = substr("stnsgobs${var.random_suffix}", 0, 24)
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-obs-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-nsg-obs-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "diagnostics" {
  name                     = local.storage_account_name
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

module "network_security_group" {
  source = "../../.."

  name                = "nsg-obs-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

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
      name                       = "nsg-obs-diagnostics"
      areas                      = ["event", "rule_counter", "metrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
      storage_account_id         = azurerm_storage_account.diagnostics.id
    }
  ]

  tags = {
    Environment = "Test"
    Scenario    = "Observability"
  }
}
