provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-linux-function-app-basic"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stlfabasic001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "example" {
  name                = "plan-linux-function-basic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

module "linux_function_app" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_linux_function_app?ref=LFUNCv1.0.0"

  name                = "funcbasicexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan_id = azurerm_service_plan.example.id

  storage_configuration = {
    account_name       = azurerm_storage_account.example.name
    account_access_key = azurerm_storage_account.example.primary_access_key
  }

  application_configuration = {
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "node"
    }
  }

  site_configuration = {
    application_stack = {
      node_version = "20"
    }
  }

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
