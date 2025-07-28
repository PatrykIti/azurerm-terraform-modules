# Private Endpoint Subnet Example
# This example demonstrates a subnet specifically configured to host private endpoints

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

# Network Security Group for private endpoint subnet
resource "azurerm_network_security_group" "example" {
  name                = var.nsg_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Allow outbound HTTPS for private endpoint communication
  security_rule {
    name                       = "AllowOutboundHTTPS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Deny all inbound traffic (private endpoints don't need inbound rules)
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

  tags = var.tags
}

# Subnet Module - Private Endpoint Configuration
module "subnet_private_endpoint" {
  source = "../../"

  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # No service endpoints needed for private endpoint subnet
  service_endpoints = []

  # No delegations for private endpoint subnet
  delegations = {}

  # CRITICAL: Disable network policies for private endpoints
  # This is required for subnets that will host private endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  tags = merge(var.tags, {
    Purpose = "PrivateEndpoints"
  })
}

# Network Security Group Association - managed at wrapper level
resource "azurerm_subnet_network_security_group_association" "subnet_pe" {
  subnet_id                 = module.subnet_private_endpoint.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Additional subnet for resources that will use private endpoints
module "subnet_resources" {
  source = "../../"

  name                 = "subnet-resources-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  # Regular subnet with network policies enabled
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  tags = merge(var.tags, {
    Purpose = "Resources"
  })
}

# Example: Storage Account to demonstrate private endpoint connectivity
resource "azurerm_storage_account" "example" {
  name                = "stpe${var.name_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public access - only accessible via private endpoint
  public_network_access_enabled = false

  tags = var.tags
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = module.subnet_private_endpoint.id

  private_service_connection {
    name                           = "psc-storage-${var.name_suffix}"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Private DNS Zone for blob storage
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "vnet-link-${var.name_suffix}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.example.id

  tags = var.tags
}

# DNS A Record for private endpoint
resource "azurerm_private_dns_a_record" "storage_blob" {
  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.storage_blob.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address]

  tags = var.tags
}