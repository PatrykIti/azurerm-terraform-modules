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

resource "azurerm_resource_group" "example" {
  name     = "rg-nsg-secure-example"
  location = var.location
}

# Supporting resources for Flow Logs and Traffic Analytics
resource "azurerm_storage_account" "flow_logs" {
  name                     = "stnsgsecure001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-nsg-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_network_watcher" "example" {
  name                = "nw-nsg-example-${azurerm_resource_group.example.location}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Application Security Groups for a three-tier application
resource "azurerm_application_security_group" "web_tier" {
  name                = "asg-web-tier"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_application_security_group" "app_tier" {
  name                = "asg-app-tier"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_application_security_group" "db_tier" {
  name                = "asg-db-tier"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Secure NSG Module
module "network_security_group" {
  source = "../../"

  name                = "nsg-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Enable Flow Logs and Traffic Analytics for security monitoring
  flow_log_enabled                      = true
  network_watcher_name                  = azurerm_network_watcher.example.name
  flow_log_storage_account_id           = azurerm_storage_account.flow_logs.id
  traffic_analytics_enabled             = true
  traffic_analytics_workspace_id        = azurerm_log_analytics_workspace.example.id
  traffic_analytics_workspace_region    = azurerm_log_analytics_workspace.example.location
  traffic_analytics_interval_in_minutes = 10

  # Zero-trust security rules
  security_rules = [
    # Inbound Rules
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all inbound traffic by default."
    },
    {
      name                                       = "AllowHttpsToWeb"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "443"
      source_address_prefix                      = "Internet"
      destination_application_security_group_ids = [azurerm_application_security_group.web_tier.id]
      description                                = "Allow inbound HTTPS to the web tier."
    },
    {
      name                                       = "AllowWebToApp"
      priority                                   = 110
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "8080"
      source_application_security_group_ids      = [azurerm_application_security_group.web_tier.id]
      destination_application_security_group_ids = [azurerm_application_security_group.app_tier.id]
      description                                = "Allow traffic from web tier to app tier."
    },
    {
      name                                       = "AllowAppToDb"
      priority                                   = 120
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "1433"
      source_application_security_group_ids      = [azurerm_application_security_group.app_tier.id]
      destination_application_security_group_ids = [azurerm_application_security_group.db_tier.id]
      description                                = "Allow traffic from app tier to database tier."
    },

    # Outbound Rules
    {
      name                       = "DenyAllOutbound"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all outbound traffic by default."
    },
    {
      name                         = "AllowPaasOutbound"
      priority                     = 100
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "443"
      source_address_prefix        = "*"
      destination_address_prefixes = ["Storage", "Sql", "AzureKeyVault"]
      description                  = "Allow outbound traffic to essential Azure PaaS services."
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Secure"
    Policy      = "Zero-Trust"
  }
}