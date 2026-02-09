provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-wfunc-basic"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "stwfuncbasic001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "asp-wfunc-basic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

module "windows_function_app" {
  source = "../../"

  name                = "wfuncbasic001"
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
    Environment = "Development"
    Example     = "Basic"
  }
}
