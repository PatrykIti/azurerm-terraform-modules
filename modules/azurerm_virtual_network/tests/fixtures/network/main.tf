# Network Test Fixture
# This fixture demonstrates network-specific features like subnets, NSGs, and network configurations

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

# Create a resource group for this test
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-net-${var.random_suffix}"
  location = var.location
}

# Create Network Security Groups for test
resource "azurerm_network_security_group" "web" {
  name                = "nsg-dpc-net-web-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-dpc-net-app-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "AllowAppPort"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}

# Create Route Table for test
resource "azurerm_route_table" "test" {
  name                = "rt-dpc-net-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}

# Network configuration with subnets and associated resources
module "virtual_network" {
  source = "../../../"

  name                = "vnet-dpc-net-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  # DNS Configuration
  dns_servers = ["10.0.0.4", "10.0.0.5"]

  # Subnet Configuration with NSG and Route Table associations
  subnets = [
    {
      name                                  = "WebSubnet"
      address_prefixes                      = ["10.0.1.0/24"]
      service_endpoints                     = ["Microsoft.Storage", "Microsoft.Sql"]
      private_endpoint_network_policies     = "Disabled"
      private_link_service_network_policies = "Disabled"
      network_security_group_id             = azurerm_network_security_group.web.id
      route_table_id                        = azurerm_route_table.test.id
    },
    {
      name                              = "AppSubnet"
      address_prefixes                  = ["10.0.2.0/24"]
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Enabled"
      network_security_group_id         = azurerm_network_security_group.app.id
    },
    {
      name              = "DatabaseSubnet"
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Sql"]
      delegation = {
        name = "postgresql-delegation"
        service_delegation = {
          name    = "Microsoft.DBforPostgreSQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  ]

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}
