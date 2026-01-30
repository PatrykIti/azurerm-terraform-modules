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
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.60.0.0/16"]
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.60.1.0/24"]
  private_endpoint_network_policies_enabled = true
}

module "cognitive_account" {
  source = "../.."

  name                = var.account_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = false
  local_auth_enabled            = false
  custom_subdomain_name         = var.custom_subdomain_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "openai" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name                  = var.private_dns_zone_link_name
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_endpoint" "openai" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-psc"
    private_connection_resource_id = module.cognitive_account.id
    subresource_names              = [var.private_endpoint_subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.private_endpoint_name}-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai.id]
  }
}
