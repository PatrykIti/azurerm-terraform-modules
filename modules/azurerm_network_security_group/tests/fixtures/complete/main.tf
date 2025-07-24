provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-cmp-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "test" {
  name                     = "stnsgcmp${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "log-nsg-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_network_watcher" "test" {
  name                = "nw-nsg-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

module "network_security_group" {
  source = "../../.."

  name                = "nsg-cmp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = [
    {
      name                       = "allow_ssh_inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/16"
      destination_address_prefix = "*"
      description                = "Allow SSH from internal network"
    },
    {
      name                       = "deny_rdp_outbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      description                = "Deny RDP to the Internet"
    }
  ]

  flow_log_enabled            = true
  network_watcher_name        = azurerm_network_watcher.test.name
  flow_log_storage_account_id = azurerm_storage_account.test.id

  traffic_analytics_enabled             = true
  traffic_analytics_workspace_id        = azurerm_log_analytics_workspace.test.workspace_id
  traffic_analytics_workspace_region    = azurerm_log_analytics_workspace.test.location
  traffic_analytics_interval_in_minutes = 10

  tags = {
    Environment = "Test"
    Scenario    = "Complete"
  }
}
