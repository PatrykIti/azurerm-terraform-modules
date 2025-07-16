# Complete Route Table Example

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-route-table-complete-example"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-hub-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Multiple Subnets for demonstration
resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "subnet-data"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"  # Special name for Azure Firewall
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Complete Route Table with all features
module "route_table_complete" {
  source = "../../"

  name                = "rt-hub-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP route propagation for full control
  disable_bgp_route_propagation = true

  # Comprehensive routes configuration
  routes = [
    {
      name                   = "to-firewall-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"  # Firewall internal IP
    },
    {
      name                   = "to-on-premises"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
    },
    {
      name                   = "to-spoke1"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name                   = "to-spoke2"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name                   = "local-vnet"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
    },
    {
      name                   = "blackhole-bad-traffic"
      address_prefix         = "1.2.3.4/32"
      next_hop_type          = "None"  # Drop traffic to this IP
    }
  ]

  # Associate with multiple subnets
  subnet_ids_to_associate = {
    (azurerm_subnet.app.id)  = azurerm_subnet.app.id,
    (azurerm_subnet.data.id) = azurerm_subnet.data.id
  }

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

  name                = "rt-dmz-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Keep BGP propagation enabled for this table
  disable_bgp_route_propagation = false

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