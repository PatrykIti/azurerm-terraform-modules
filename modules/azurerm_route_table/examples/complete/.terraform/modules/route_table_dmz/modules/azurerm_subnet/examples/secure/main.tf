# Simplified Secure Subnet Example
# This example demonstrates a basic but secure Subnet configuration

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

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-secure-example"
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment   = "Production"
    Example       = "Secure"
    Purpose       = "Secure Virtual Network"
    SecurityLevel = "High"
  }
}

# Create restrictive Network Security Group
resource "azurerm_network_security_group" "secure" {
  name                = "nsg-subnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Allow only HTTPS inbound from specific IP ranges
  security_rule {
    name                       = "AllowHTTPSFromTrustedIPs"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = ["203.0.113.0/24", "198.51.100.0/24"] # Replace with your trusted IP ranges
    destination_address_prefix = "*"
  }

  # Allow internal VNet communication
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = {
    Environment   = "Production"
    Purpose       = "Network Security"
    SecurityLevel = "High"
  }
}

# Secure Subnet configuration
module "subnet" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.2"

  name                 = "subnet-secure-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service endpoints for secure access to Azure services
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]

  # Enable network policies for enhanced security
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Associate Network Security Group with Subnet
resource "azurerm_subnet_network_security_group_association" "secure" {
  subnet_id                 = module.subnet.id
  network_security_group_id = azurerm_network_security_group.secure.id

  depends_on = [module.subnet]
}