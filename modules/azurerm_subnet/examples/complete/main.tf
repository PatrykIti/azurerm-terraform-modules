# Complete Subnet Example
# This example demonstrates all features of the subnet module

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
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

# Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = var.nsg_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Route Table
resource "azurerm_route_table" "example" {
  name                = var.route_table_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  route {
    name           = "DefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }

  tags = var.tags
}

# Service Endpoint Policy
resource "azurerm_subnet_service_endpoint_storage_policy" "example" {
  name                = var.service_endpoint_policy_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  definition {
    name              = "definition1"
    service_resources = ["/subscriptions/*/resourceGroups/*/providers/Microsoft.Storage/storageAccounts/*"]
    description       = "Allow all storage accounts"
  }

  tags = var.tags
}

# Subnet Module - Complete Configuration
module "subnet" {
  source = "../../"

  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service Endpoints
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.AzureCosmosDB",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus"
  ]

  # Service Endpoint Policies
  service_endpoint_policy_ids = [azurerm_subnet_service_endpoint_storage_policy.example.id]

  # Subnet Delegation for Container Instances
  delegations = {
    aci = {
      name = "Microsoft.ContainerInstance/containerGroups"
      service_delegation = {
        name = "Microsoft.ContainerInstance/containerGroups"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action",
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }

  # Network Policies
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  tags = var.tags
}

# Network Security Group Association - managed at wrapper level
resource "azurerm_subnet_network_security_group_association" "subnet" {
  subnet_id                 = module.subnet.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Route Table Association - managed at wrapper level
resource "azurerm_subnet_route_table_association" "subnet" {
  subnet_id      = module.subnet.id
  route_table_id = azurerm_route_table.example.id
}

# Additional subnet without delegation to show multiple subnet patterns
module "subnet_no_delegation" {
  source = "../../"

  name                 = var.subnet_no_delegation_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  # Only basic service endpoints
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]

  # Network policies enabled (default)
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  tags = merge(var.tags, {
    Type = "No-Delegation"
  })
}