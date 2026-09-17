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

# Storage account for diagnostic settings
resource "azurerm_storage_account" "diagnostics" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# Event Hub for diagnostic settings (optional destination)
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

# Application Security Groups for demonstration
resource "azurerm_application_security_group" "web_servers" {
  name                = "asg-web-servers"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Web Servers"
  }
}

resource "azurerm_application_security_group" "database_servers" {
  name                = "asg-database-servers"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Database Servers"
  }
}

# Main NSG module with complete configuration
module "network_security_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_network_security_group?ref=NSGv1.1.0"

  name                = "nsg-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Comprehensive Security Rules
  security_rules = [
    # Service Tag Example
    {
      name                       = "allow_azure_load_balancer"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow Azure Load Balancer probes"
    },
    # Multiple Port Ranges Example
    {
      name                       = "allow_web_traffic"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["80", "443", "8080-8090"]
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow web traffic on multiple ports"
    },
    # Multiple Address Prefixes Example
    {
      name                       = "allow_management_subnets"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389"]
      source_address_prefixes    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow SSH/RDP from management subnets"
    },
    # Application Security Group Example
    {
      name                                       = "allow_web_to_db"
      priority                                   = 130
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "1433"
      source_application_security_group_ids      = [azurerm_application_security_group.web_servers.id]
      destination_application_security_group_ids = [azurerm_application_security_group.database_servers.id]
      description                                = "Allow SQL Server access from web servers to database servers"
    },
    # Outbound Rule Example
    {
      name                       = "allow_internet_https"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Internet"
      description                = "Allow HTTPS outbound to Internet"
    },
    # Deny Rule Example
    {
      name                       = "deny_all_inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other inbound traffic"
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
