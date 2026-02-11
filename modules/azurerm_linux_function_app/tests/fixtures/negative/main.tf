# Negative test cases - should fail validation
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-linux-function-negative-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stlfaneg${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "example" {
  name                = "plan-linux-function-negative-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# This should fail due to invalid name
module "linux_function_app" {
  source = "../../../"

  name                = "INVALID-NAME-WITH-UPPERCASE"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  service_plan_id = azurerm_service_plan.example.id

  storage_configuration = {
    account_name       = azurerm_storage_account.example.name
    account_access_key = azurerm_storage_account.example.primary_access_key
  }

  site_configuration = {
    application_stack = {
      node_version = "20"
    }
  }

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
