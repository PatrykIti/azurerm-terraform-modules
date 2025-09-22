# Complete Virtual Network Example
# This example demonstrates a comprehensive Virtual Network configuration with all features

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

# Create a resource group for this test
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-cmp-${var.random_suffix}"
  location = var.location
}

# Create a second resource group for peering test
resource "azurerm_resource_group" "peer" {
  name     = "rg-dpc-peer-${var.random_suffix}"
  location = var.location
}

# Create a peer Virtual Network for peering test
resource "azurerm_virtual_network" "peer" {
  name                = "vnet-dpc-peer-${var.random_suffix}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.peer.location
  resource_group_name = azurerm_resource_group.peer.name

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Complete-Peering"
  }
}

# Create Log Analytics Workspace for diagnostic settings
resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-dpc-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Complete"
  }
}

# Create Storage Account for diagnostic settings
resource "azurerm_storage_account" "test" {
  name                     = "stdpccmp${lower(var.random_suffix)}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Complete"
  }
}

# Create Private DNS Zone for test
resource "azurerm_private_dns_zone" "test" {
  name                = "test.internal"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Complete"
  }
}

# Complete Virtual Network configuration with all features
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.3"

  name                = "vnet-dpc-cmp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16", "10.2.0.0/16"]

  # DNS Configuration
  dns_servers = ["10.0.1.4", "10.0.1.5"]

  # Network Flow Configuration
  flow_timeout_in_minutes = 10

  # BGP Community (example for ExpressRoute)
  bgp_community = "12076:20000"

  # Encryption Configuration
  encryption = {
    enforcement = "AllowUnencrypted"
  }


  # Lifecycle Management

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Complete"
  }
}

# Virtual Network Peering - now managed as separate resource
resource "azurerm_virtual_network_peering" "test" {
  name                         = "peer-to-vnet-peer"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = module.virtual_network.name
  remote_virtual_network_id    = azurerm_virtual_network.peer.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  # Triggers for recreation when peering configuration changes
  triggers = {
    remote_address_space = join(",", azurerm_virtual_network.peer.address_space)
  }

  depends_on = [module.virtual_network]
}

# Private DNS Zone Virtual Network Link - now managed as separate resource
resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  name                  = "link-to-example-internal"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = azurerm_private_dns_zone.test.name
  virtual_network_id    = module.virtual_network.id
  registration_enabled  = true

  tags = {
    Purpose     = "DNS Resolution"
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Complete"
  }

  depends_on = [module.virtual_network]
}

# Diagnostic Settings - now managed as separate resource
resource "azurerm_monitor_diagnostic_setting" "test" {
  name                       = "${module.virtual_network.name}-diag"
  target_resource_id         = module.virtual_network.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  storage_account_id         = azurerm_storage_account.test.id

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
