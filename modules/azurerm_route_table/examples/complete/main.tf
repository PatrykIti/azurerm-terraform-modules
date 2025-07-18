# Complete Route Table Example

# Resource Group
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-rt-complete-${random_string.suffix.result}"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-hub-complete-${random_string.suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Multiple Subnets for demonstration
resource "azurerm_subnet" "app" {
  name                 = "snet-app-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data-${random_string.suffix.result}"
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

  name                = "rt-hub-complete-${random_string.suffix.result}"
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

  # Associate with multiple subnets
  subnet_ids_to_associate = [
    azurerm_subnet.app.id,
    azurerm_subnet.data.id
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

  name                = "rt-dmz-${random_string.suffix.result}"
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
