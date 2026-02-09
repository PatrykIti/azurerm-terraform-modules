provider "azurerm" {
  features {}
}

locals {
  suffix               = substr(var.random_suffix, 0, 8)
  resource_group_name  = "rg-wfunc-basic-${local.suffix}"
  storage_account_name = "stwfbasic${local.suffix}"
  service_plan_name    = "asp-wfunc-basic-${local.suffix}"
  function_app_name    = "wfuncbasic${local.suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = local.service_plan_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

module "windows_function_app" {
  source = "../../../"

  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.example.id

  storage_configuration = {
    account_name       = azurerm_storage_account.example.name
    account_access_key = azurerm_storage_account.example.primary_access_key
  }

  application_configuration = {
    functions_extension_version = "~4"
  }

  access_configuration = {
    public_network_access_enabled = true
  }

  site_config = {
    application_stack = {
      dotnet_version = "v8.0"
    }
  }

  tags = {
    Environment = "Test"
    TestType    = "Basic"
    Owner       = "terratest"
  }
}
