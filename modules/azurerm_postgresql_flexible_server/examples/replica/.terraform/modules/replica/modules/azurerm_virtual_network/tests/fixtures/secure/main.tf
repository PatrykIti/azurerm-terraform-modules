# Secure Virtual Network Example
# This example demonstrates a security-focused Virtual Network configuration

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

# Create a resource group for this example
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-sec-${var.random_suffix}"
  location = var.location
}

# Create Log Analytics Workspace for security monitoring
resource "azurerm_log_analytics_workspace" "security" {
  name                = "law-dpc-sec-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 90 # Extended retention for security logs

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
}

# Create Storage Account for security logs
resource "azurerm_storage_account" "security" {
  name                     = "stdpcsec${lower(var.random_suffix)}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant for security logs

  # Security settings
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  # Required for tests from public networks.
  public_network_access_enabled = true
  # Required for provider data plane reads during tests.
  shared_access_key_enabled       = true
  allow_nested_items_to_be_public = false

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
}

# Network Watcher configuration is in network_watcher.tf
# It handles automatic detection of existing default Network Watcher

# Create Network Security Group for additional security
resource "azurerm_network_security_group" "test" {
  name                = "nsg-dpc-sec-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  # Deny all inbound traffic by default
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
}

# Secure Virtual Network configuration with enhanced security features
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  name                = "vnet-dpc-sec-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  # Use custom DNS servers for better security control
  dns_servers = ["10.0.1.4", "10.0.1.5"]

  # Network Flow Configuration
  flow_timeout_in_minutes = 30 # Maximum timeout for better tracking

  # DDoS Protection Plan disabled due to Azure subscription limitation
  # (only 1 DDoS plan allowed per subscription per region)
  ddos_protection_plan = null

  # Encryption Configuration - allow unencrypted (subscription limitation)
  encryption = {
    enforcement = "AllowUnencrypted"
  }


  # Lifecycle Management - prevent accidental deletion

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }

}


# Diagnostic Settings - now managed as separate resource for security monitoring
resource "azurerm_monitor_diagnostic_setting" "test" {
  name                       = "${module.virtual_network.name}-diag"
  target_resource_id         = module.virtual_network.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id
  storage_account_id         = azurerm_storage_account.security.id

  # Virtual Network Logs
  enabled_log {
    category = "VMProtectionAlerts"
  }

  # Virtual Network Metrics
  enabled_metric {
    category = "AllMetrics"
  }

  depends_on = [module.virtual_network]
}
