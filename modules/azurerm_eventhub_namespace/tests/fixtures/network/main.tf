# Event Hub Namespace Network Rule Set Example

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

locals {
  suffix = var.random_suffix == "" ? "" : "-${var.random_suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group_name}${local.suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ehns-network${local.suffix}"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "eventhub" {
  name                 = "snet-ehns-network${local.suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]
  service_endpoints    = ["Microsoft.EventHub"]
}

module "eventhub_namespace" {
  source = "../../../"

  name                = "${var.namespace_name}${local.suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku                           = "Standard"
  public_network_access_enabled = true

  network_rule_set = {
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true
    ip_rules = [
      {
        ip_mask = "203.0.113.0/24"
      }
    ]
    vnet_rules = [
      {
        subnet_id = azurerm_subnet.eventhub.id
      }
    ]
  }

  tags = {
    Environment = "Development"
    Example     = "NetworkRuleSet"
  }
}
