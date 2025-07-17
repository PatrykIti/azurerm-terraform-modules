terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-sec-${var.random_suffix}"
  location = var.location
}

module "storage_account" {
  source = "../../../"

  name                     = "dpcsec${random_string.suffix.result}${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    shared_access_key_enabled       = true # Required for Terraform to manage
  }

  # Encryption configuration
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
  }

  # Identity for encryption
  identity = {
    type = "SystemAssigned"
  }

  # Network security - deny all by default
  network_rules = {
    default_action = "Deny"
    ip_rules       = []
    subnet_ids     = []
    bypass         = []
  }

  tags = {
    Environment = "Test"
    TestType    = "Security"
    Compliance  = "High"
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "identity_principal_id" {
  value = try(module.storage_account.identity.principal_id, null)
}