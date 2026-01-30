# Network integration test fixture (IP restrictions)
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-linux-function-network-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stlfanet${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "example" {
  name                = "plan-linux-function-network-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

module "linux_function_app" {
  source = "../../../"

  name                = "funcnet${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  service_plan_id            = azurerm_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  site_config = {
    ip_restriction_default_action = "Deny"
    application_stack = {
      node_version = "20"
    }
    ip_restriction = [
      {
        name       = "office"
        ip_address = "203.0.113.0/24"
        action     = "Allow"
        priority   = 100
      }
    ]
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
