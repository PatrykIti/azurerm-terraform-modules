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
  name     = "rg-ai-services-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ai-services-${var.random_suffix}"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-ai-services-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]

  service_endpoints = ["Microsoft.CognitiveServices"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ai-services-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "ai_services_account" {
  source = "../../.."

  name                = "aiservices-complete-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S0"

  public_network_access        = "Enabled"
  local_authentication_enabled = true
  custom_subdomain_name        = "aiservices${var.random_suffix}"

  identity = {
    type = "SystemAssigned"
  }

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.allowed_ip_range]
    virtual_network_rules = [{
      subnet_id = azurerm_subnet.example.id
    }]
  }

  diagnostic_settings = [{
    name                       = "ai-services-diagnostics-${var.random_suffix}"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    areas                      = ["all"]
  }]

  tags = var.tags
}
