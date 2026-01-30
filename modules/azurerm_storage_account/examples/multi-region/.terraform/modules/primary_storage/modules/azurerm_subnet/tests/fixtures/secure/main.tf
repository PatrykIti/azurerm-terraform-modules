terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment   = "Production"
    Example       = "Secure"
    SecurityLevel = "High"
  }
}

resource "azurerm_network_security_group" "secure" {
  name                = "nsg-subnet-secure-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment   = "Production"
    Purpose       = "Network Security"
    SecurityLevel = "High"
  }
}

module "subnet" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                 = "snet-subnet-secure-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  associations = {
    network_security_group = {
      id = azurerm_network_security_group.secure.id
    }
  }
}
