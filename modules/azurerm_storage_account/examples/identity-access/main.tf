terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.3"
}

provider "azurerm" {
  subscription_id = "df86479f-16c4-4326-984c-14929d7899e3"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# Create a resource group for the example
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-identity-example"
  location = "West Europe"
}

# Create storage account with system-assigned managed identity
module "storage_account" {
  source = "../.."

  # Basic configuration
  name                     = "stidentityexample${substr(md5(timestamp()), 0, 8)}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Enable system-assigned managed identity
  identity = {
    type = "SystemAssigned"
  }

  # Enable OAuth authentication as default and disable shared keys
  default_to_oauth_authentication = true

  # Security settings with disabled shared access keys for true keyless authentication
  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = false # Keyless authentication - no shared keys
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = true
    enable_advanced_threat_protection = true
  }

  # Network rules allowing only Azure services by default
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = []
  }

  tags = {
    example     = "identity-access"
    environment = "development"
    purpose     = "keyless-authentication-demo"
  }
}

# Grant Storage Blob Data Contributor role to the current user
# This allows testing with Azure CLI using --auth-mode login
resource "azurerm_role_assignment" "current_user_access" {
  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Create a container for testing identity-based access
resource "azurerm_storage_container" "test" {
  name                  = "test-container"
  storage_account_name  = module.storage_account.name
  container_access_type = "private"

  depends_on = [
    azurerm_role_assignment.current_user_access
  ]
}

# Example: Grant the storage account's managed identity access to a Key Vault
# This demonstrates how the storage account can access other Azure resources
resource "azurerm_key_vault" "example" {
  name                = "kv-identity-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable RBAC authorization for Key Vault
  enable_rbac_authorization = true
}

# Grant the storage account's managed identity access to Key Vault secrets
resource "azurerm_role_assignment" "storage_identity_keyvault_access" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.storage_account.identity.principal_id
}

# Example of granting a specific Azure AD group access to the storage account
# Uncomment and update the object_id to use
# resource "azurerm_role_assignment" "group_access" {
#   scope                = module.storage_account.id
#   role_definition_name = "Storage Blob Data Reader"
#   principal_id         = "YOUR-AZURE-AD-GROUP-OBJECT-ID"
# }