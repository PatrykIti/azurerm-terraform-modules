# Secure Subnet Example
# This example demonstrates a security-focused subnet configuration

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

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-secure-${var.name_suffix}"
  location = var.location

  tags = var.tags
}

# Virtual Network with DDoS Protection (optional)
resource "azurerm_virtual_network" "example" {
  name                = "vnet-secure-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  # Enable DDoS protection for production environments
  # Uncomment if you have DDoS Protection Plan
  # ddos_protection_plan {
  #   id     = azurerm_network_ddos_protection_plan.example.id
  #   enable = true
  # }

  tags = var.tags
}

# Network Security Group with restrictive rules
resource "azurerm_network_security_group" "example" {
  name                = "nsg-secure-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Deny all inbound traffic by default (implicit)
  # Only allow specific required traffic

  # Example: Allow HTTPS from specific IP ranges only
  security_rule {
    name                       = "AllowHTTPSFromCorporate"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = ["203.0.113.0/24", "198.51.100.0/24"] # Replace with your corporate IP ranges
    destination_address_prefix = "*"
  }

  # Example: Allow SSH from bastion subnet only
  security_rule {
    name                       = "AllowSSHFromBastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.254.0/24" # Bastion subnet
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic explicitly
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound to specific services only
  security_rule {
    name                         = "AllowOutboundToAzureServices"
    priority                     = 100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefix        = "*"
    destination_address_prefix   = "AzureCloud"
  }

  tags = var.tags
}

# Route Table to force traffic through firewall/NVA
resource "azurerm_route_table" "example" {
  name                          = "rt-secure-${var.name_suffix}"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = true

  # Force all internet traffic through firewall
  route {
    name                   = "ForceInternetThroughFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.250.4" # Replace with your firewall IP
  }

  # Route to other vnets through firewall
  route {
    name                   = "ForceVNetThroughFirewall"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.250.4" # Replace with your firewall IP
  }

  tags = var.tags
}

# Service Endpoint Policy to restrict access to specific storage accounts
resource "azurerm_subnet_service_endpoint_storage_policy" "example" {
  name                = "sep-secure-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  definition {
    name = "AllowSpecificStorageAccounts"
    service_resources = [
      # Replace with your specific storage account resource IDs
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stgsecure001",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stgsecure002"
    ]
    description = "Allow access only to specific storage accounts"
  }

  tags = var.tags
}

# Secure Subnet Module Configuration
module "subnet" {
  source = "../../"

  name                 = "subnet-secure-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Mandatory NSG association for security
  network_security_group_id = azurerm_network_security_group.example.id

  # Force traffic through firewall
  route_table_id = azurerm_route_table.example.id

  # Enable service endpoints for key services with restrictions
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]

  # Apply service endpoint policies to restrict access
  service_endpoint_policy_ids = [azurerm_subnet_service_endpoint_storage_policy.example.id]

  # No delegations for security - dedicated subnet
  delegations = {}

  # Enable network policies for additional security
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  tags = merge(var.tags, {
    SecurityLevel = "High"
    Compliance    = "Required"
  })
}

# Additional secure subnet for private endpoints
module "subnet_private_endpoints" {
  source = "../../"

  name                 = "subnet-pe-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  # Mandatory NSG for private endpoint subnet
  network_security_group_id = azurerm_network_security_group.example.id

  # No service endpoints on private endpoint subnet
  service_endpoints = []

  # Disable network policies for private endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  tags = merge(var.tags, {
    Purpose = "PrivateEndpoints"
  })
}