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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-msa-${var.random_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = "kvmsa${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

module "key_vault" {
  source = "../../../"

  name                = "kvmsa${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  access_policies = [
    {
      name                = "current-user"
      object_id           = data.azurerm_client_config.current.object_id
      tenant_id           = data.azurerm_client_config.current.tenant_id
      storage_permissions = ["Get", "List", "Set", "Delete", "GetSAS", "SetSAS", "RegenerateKey"]
    }
  ]

  managed_storage_accounts = [
    {
      name                         = "appstorage"
      storage_account_id           = azurerm_storage_account.example.id
      storage_account_key          = azurerm_storage_account.example.primary_access_key
      regenerate_key_automatically = true
      regeneration_period          = "P30D"
    }
  ]

  managed_storage_sas_definitions = [
    {
      name                         = "appstorage-sas"
      managed_storage_account_name = "appstorage"
      sas_template_uri             = format("https://%s.blob.core.windows.net/?sv=2022-11-02&ss=b&srt=sco&sp=rl&se=2099-01-01T00:00:00Z", azurerm_storage_account.example.name)
      sas_type                     = "service"
      validity_period              = "P30D"
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "ManagedStorage"
  }
}
