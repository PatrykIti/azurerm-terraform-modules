provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]

  service_endpoints = ["Microsoft.CognitiveServices"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "ai_services_account" {
  source = "../../"

  name                = var.ai_services_account_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = var.sku_name

  public_network_access        = "Enabled"
  local_authentication_enabled = true
  custom_subdomain_name        = var.custom_subdomain_name

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
    name                       = var.diagnostic_setting_name
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    areas                      = ["all"]
  }]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
