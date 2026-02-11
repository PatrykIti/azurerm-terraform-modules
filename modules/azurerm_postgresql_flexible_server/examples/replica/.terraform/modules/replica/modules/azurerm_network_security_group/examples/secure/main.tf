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

# Log Analytics workspace for diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_network_security_group?ref=NSGv1.1.0"

  name                = "nsg-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

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
      priority                   = 4095
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
      name                       = "AllowPaasOutbound"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud.WestEurope"
      description                = "Allow outbound traffic to essential Azure PaaS services."
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Secure"
    Policy      = "Zero-Trust"
  }
}
