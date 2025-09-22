# Network Test Fixture
# This fixture demonstrates how virtual network integrates with other network resources
# using separate resource blocks (NSG, Route Table, Subnets)

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
  name     = "rg-dpc-net-${var.random_suffix}"
  location = var.location
}

# Virtual Network - Simple module call without subnets
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.3"

  name                    = "vnet-dpc-net-${var.random_suffix}"
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  address_space           = ["10.0.0.0/16"]
  dns_servers             = ["10.0.0.4", "10.0.0.5"]
  flow_timeout_in_minutes = 20

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}

# Create Network Security Groups
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
    name                       = "AllowWebSubnet"
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

# Create Route Tables
resource "azurerm_route_table" "web" {
  name                          = "rt-dpc-net-web-${var.random_suffix}"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  bgp_route_propagation_enabled = true

  route {
    name           = "ToInternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}

resource "azurerm_route_table" "app" {
  name                          = "rt-dpc-net-app-${var.random_suffix}"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  bgp_route_propagation_enabled = true

  route {
    name                   = "ToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
  }
}

# Create Subnets as separate resources
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# Associate Route Tables with Subnets
resource "azurerm_subnet_route_table_association" "web" {
  subnet_id      = azurerm_subnet.web.id
  route_table_id = azurerm_route_table.web.id
}

resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = azurerm_route_table.app.id
}

# Create Hub Virtual Network for peering test
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-dpc-net-hub-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
    Role        = "Hub"
  }
}

# Create Spoke Virtual Network for peering test
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-dpc-net-spk-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.2.0.0/16"]

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Network"
    Role        = "Spoke"
  }
}

# Create peering from Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Create peering from Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
