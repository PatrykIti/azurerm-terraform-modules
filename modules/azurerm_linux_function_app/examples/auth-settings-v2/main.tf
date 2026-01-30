provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-linux-function-app-authv2"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stlfaauthv2001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "example" {
  name                = "plan-linux-function-authv2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

module "linux_function_app" {
  source = "../../"

  name                = "funcauthv2example001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan_id            = azurerm_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    AAD_CLIENT_SECRET        = var.aad_client_secret
  }

  site_config = {
    application_stack = {
      node_version = "20"
    }
  }

  auth_settings_v2 = {
    auth_enabled           = true
    default_provider       = "azureactivedirectory"
    unauthenticated_action = "RedirectToLoginPage"
    require_https          = true

    login = {
      token_store_enabled = true
    }

    active_directory_v2 = {
      client_id                  = var.aad_client_id
      tenant_auth_endpoint       = var.aad_tenant_endpoint
      client_secret_setting_name = "AAD_CLIENT_SECRET"
    }
  }

  tags = {
    Environment = "Development"
    Example     = "AuthV2"
  }
}
