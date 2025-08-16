terraform {
  required_version = ">= 1.12.2"

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
  name     = "rg-nsg-complete-example"
  location = var.location
}


# Create Application Security Groups for demonstration
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
  source = "../../"

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