# Secure Virtual Network Example
# This example demonstrates a security-focused Virtual Network configuration

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
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

# DDoS Protection Plan detection - Azure allows only ONE per region per subscription
# Check if DDoS Protection Plan exists and use it, or create new if it doesn't
data "external" "ddos_protection_check" {
  program = ["bash", "-c", <<-EOT
    # Normalize location to match Azure format (lowercase, no spaces)
    NORMALIZED_LOCATION=$(echo "${var.location}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    
    # Check if DDoS Protection Plan exists in the region
    DDOS_LIST=$(az network ddos-protection list --query "[?location=='$NORMALIZED_LOCATION']" -o json 2>/dev/null || echo '[]')
    
    # If we found any DDoS Protection Plans, return the first one
    if [ "$(echo "$DDOS_LIST" | jq 'length')" -gt "0" ]; then
      echo "$DDOS_LIST" | jq '.[0] | {name: .name, resourceGroup: .resourceGroup, id: .id}'
    else
      # Return empty values to indicate no DDoS Protection Plan exists
      echo '{"name": "", "resourceGroup": "", "id": ""}'
    fi
  EOT
  ]
}

locals {
  # Check if we found an existing DDoS Protection Plan
  ddos_protection_exists = data.external.ddos_protection_check.result.name != ""

  # Final values to use
  ddos_protection_plan_id = local.ddos_protection_exists ? data.external.ddos_protection_check.result.id : azurerm_network_ddos_protection_plan.test[0].id
}

# Create DDoS Protection Plan only if it doesn't exist in the region
resource "azurerm_network_ddos_protection_plan" "test" {
  count               = local.ddos_protection_exists ? 0 : 1
  name                = "ddos-dpc-sec-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
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
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  shared_access_key_enabled       = true # Required for flow logs
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
  source = "../../../"

  name                = "vnet-dpc-sec-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  # Use custom DNS servers for better security control
  dns_servers = ["10.0.1.4", "10.0.1.5"]

  # Network Flow Configuration
  flow_timeout_in_minutes = 30 # Maximum timeout for better tracking

  # DDoS Protection Plan for enhanced security
  ddos_protection_plan = {
    id     = local.ddos_protection_plan_id
    enable = true
  }

  # Encryption Configuration - allow unencrypted (subscription limitation)
  encryption = {
    enforcement = "AllowUnencrypted"
  }

  # Network Watcher Flow Log for security monitoring
  flow_log = {
    network_watcher_name                = local.network_watcher_name
    network_watcher_resource_group_name = local.network_watcher_rg
    network_security_group_id           = azurerm_network_security_group.test.id
    storage_account_id                  = azurerm_storage_account.security.id
    enabled                             = true
    version                             = 2
    retention_policy = {
      enabled = true
      days    = 90
    }
    traffic_analytics = {
      enabled               = true
      workspace_id          = azurerm_log_analytics_workspace.security.workspace_id
      workspace_region      = azurerm_log_analytics_workspace.security.location
      workspace_resource_id = azurerm_log_analytics_workspace.security.id
      interval_in_minutes   = 10
    }
  }

  # Comprehensive diagnostic settings for security monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id
    storage_account_id         = azurerm_storage_account.security.id
    logs = {
      vm_protection_alerts = true
    }
    metrics = {
      all_metrics = true
    }
  }

  # Lifecycle Management - prevent accidental deletion

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
}
