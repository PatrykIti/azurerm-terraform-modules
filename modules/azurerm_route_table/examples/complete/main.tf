# Complete Route Table Example
# This example demonstrates a comprehensive deployment of Route Tables with all available features

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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "df86479f-16c4-4326-984c-14929d7899e3"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Multiple Subnets for demonstration
resource "azurerm_subnet" "app" {
  name                 = var.subnet_app_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = var.subnet_data_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet" # Special name for Azure Firewall
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Complete Route Table with all features
module "route_table_complete" {
  source = "../../"

  name                = var.route_table_hub_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP route propagation for full control
  bgp_route_propagation_enabled = false

  # Comprehensive routes configuration
  routes = [
    {
      name                   = "to-firewall-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4" # Firewall internal IP
    },
    {
      name           = "to-on-premises"
      address_prefix = "192.168.0.0/16"
      next_hop_type  = "VirtualNetworkGateway"
    },
    {
      name           = "local-vnet"
      address_prefix = "10.0.0.0/16"
      next_hop_type  = "VnetLocal"
    },
    {
      name           = "blackhole-bad-traffic"
      address_prefix = "1.2.3.4/32"
      next_hop_type  = "None" # Drop traffic to this IP
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Complete"
    Purpose     = "Hub-Spoke-Firewall"
    ManagedBy   = "Terraform"
  }
}

# Additional route table for different routing needs
module "route_table_dmz" {
  source = "../../"

  name                = var.route_table_dmz_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Keep BGP propagation enabled for this table
  bgp_route_propagation_enabled = true

  routes = [
    {
      name           = "internet-direct"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Complete"
    Purpose     = "DMZ"
    ManagedBy   = "Terraform"
  }
}

# Subnet Route Table Associations - managed at the example level
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = module.route_table_complete.id
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = azurerm_subnet.data.id
  route_table_id = module.route_table_complete.id
}
