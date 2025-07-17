# Secure Virtual Network Example
# This example demonstrates a security-focused Virtual Network configuration

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
resource "azurerm_resource_group" "example" {
  name     = "rg-vnet-secure-example"
  location = var.location
}

# Create DDoS Protection Plan for enhanced security
resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "ddos-vnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Production"
    Purpose     = "DDoS Protection"
  }
}

# Create Log Analytics Workspace for security monitoring
resource "azurerm_log_analytics_workspace" "security" {
  name                = "law-vnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90 # Extended retention for security logs

  tags = {
    Environment = "Production"
    Purpose     = "Security Monitoring"
  }
}

# Create Storage Account for security logs
resource "azurerm_storage_account" "security" {
  name                     = "stvnetsecureexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant for security logs

  # Security settings
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  shared_access_key_enabled       = true # Required for flow logs
  allow_nested_items_to_be_public = false

  tags = {
    Environment = "Production"
    Purpose     = "Security Logs Storage"
  }
}

# Create Network Watcher for flow logs
resource "azurerm_network_watcher" "example" {
  name                = "nw-vnet-secure-example-${var.location}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Production"
    Purpose     = "Network Monitoring"
  }
}

# Create Network Security Group for additional security
resource "azurerm_network_security_group" "example" {
  name                = "nsg-vnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

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
    Environment = "Production"
    Purpose     = "Network Security"
  }
}

# Secure Virtual Network configuration with enhanced security features
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_virtual_network?ref=VNv1.0.0"

  name                = "vnet-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # Use custom DNS servers for better security control
  dns_servers = ["10.0.1.4", "10.0.1.5"]

  # Network Flow Configuration
  flow_timeout_in_minutes = 30 # Maximum timeout for better tracking

  # DDoS Protection Plan for enhanced security
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  # Encryption Configuration - allow unencrypted (subscription limitation)
  encryption = {
    enforcement = "AllowUnencrypted"
  }

  # Network Watcher Flow Log for security monitoring
  flow_log = {
    network_watcher_name                = azurerm_network_watcher.example.name
    network_watcher_resource_group_name = azurerm_resource_group.example.name
    network_security_group_id           = azurerm_network_security_group.example.id
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
    Environment   = "Production"
    Example       = "Secure"
    Purpose       = "Secure Virtual Network Example"
    SecurityLevel = "High"
    Compliance    = "Required"
    Owner         = "Security Team"
    CostCenter    = "Security-Infrastructure"
  }
}
