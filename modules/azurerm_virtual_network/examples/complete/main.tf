# Complete Virtual Network Example
# This example demonstrates a comprehensive Virtual Network configuration with all features

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-vnet-complete-example"
  location = "West Europe"
}

# Create a second resource group for peering example
resource "azurerm_resource_group" "peer" {
  name     = "rg-vnet-peer-example"
  location = "West Europe"
}

# Create a peer Virtual Network for peering demonstration
resource "azurerm_virtual_network" "peer" {
  name                = "vnet-peer-example"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.peer.location
  resource_group_name = azurerm_resource_group.peer.name

  tags = {
    Environment = "Development"
    Purpose     = "Peering Example"
  }
}

# Create Log Analytics Workspace for diagnostic settings
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-vnet-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Development"
    Purpose     = "Virtual Network Monitoring"
  }
}

# Create Storage Account for diagnostic settings
resource "azurerm_storage_account" "example" {
  name                     = "stvnetcompleteexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Purpose     = "Virtual Network Diagnostics"
  }
}

# Create Private DNS Zone for demonstration
resource "azurerm_private_dns_zone" "example" {
  name                = "example.internal"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Private DNS Example"
  }
}

# Complete Virtual Network configuration with all features
module "virtual_network" {
  source = "../../"

  name                = "vnet-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
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

  # Virtual Network Peerings
  peerings = [
    {
      name                         = "peer-to-vnet-peer"
      remote_virtual_network_id    = azurerm_virtual_network.peer.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
      triggers = {
        remote_address_space = join(",", azurerm_virtual_network.peer.address_space)
      }
    }
  ]

  # Private DNS Zone Links
  private_dns_zone_links = [
    {
      name                  = "link-to-example-internal"
      resource_group_name   = azurerm_resource_group.example.name
      private_dns_zone_name = azurerm_private_dns_zone.example.name
      registration_enabled  = true
      tags = {
        Purpose = "DNS Resolution"
      }
    }
  ]

  # Diagnostic Settings
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    storage_account_id         = azurerm_storage_account.example.id
    logs = {
      vm_protection_alerts = true
    }
    metrics = {
      all_metrics = true
    }
  }

  # Lifecycle Management

  tags = {
    Environment = "Development"
    Example     = "Complete"
    Purpose     = "Virtual Network Complete Example"
    Owner       = "Platform Team"
    CostCenter  = "IT-Infrastructure"
  }
}
