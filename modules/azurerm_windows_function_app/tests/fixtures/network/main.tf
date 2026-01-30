variable "random_suffix" {
  type = string
}

variable "location" {
  type = string
}

provider "azurerm" {
  features {}
}

locals {
  suffix               = substr(var.random_suffix, 0, 8)
  resource_group_name  = "rg-wfunc-net-${local.suffix}"
  storage_account_name = "stwfn${local.suffix}"
  service_plan_name    = "asp-wfunc-net-${local.suffix}"
  function_app_name    = "wfuncnet${local.suffix}"
}

resource "azurerm_resource_group" "test" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = local.service_plan_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Windows"
  sku_name            = "EP1"
}

module "windows_function_app" {
  source = "../../../"

  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  functions_extension_version   = "~4"
  public_network_access_enabled = true

  site_config = {
    ip_restriction_default_action = "Deny"
    ip_restriction = [
      {
        name       = "office"
        priority   = 100
        action     = "Allow"
        ip_address = "203.0.113.0/24"
      }
    ]
    application_stack = {
      node_version = "~18"
    }
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
