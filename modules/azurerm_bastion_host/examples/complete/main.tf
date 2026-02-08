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
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

resource "azurerm_public_ip" "example" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "bastion_host" {
  source = "../.."

  name                = var.bastion_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku         = "Standard"
  scale_units = 2

  ip_configuration = [
    {
      name                 = var.ip_configuration_name
      subnet_id            = azurerm_subnet.bastion.id
      public_ip_address_id = azurerm_public_ip.example.id
    }
  ]

  copy_paste_enabled        = true
  file_copy_enabled         = true
  ip_connect_enabled        = true
  shareable_link_enabled    = true
  tunneling_enabled         = true
  kerberos_enabled          = true
  session_recording_enabled = false

  diagnostic_settings = [
    {
      name                           = "diag-bastion-complete"
      log_category_groups            = ["allLogs"]
      metric_categories              = ["AllMetrics"]
      log_analytics_workspace_id     = azurerm_log_analytics_workspace.example.id
      log_analytics_destination_type = "Dedicated"
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Complete"
    Owner       = "platform"
  }
}
