provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-test-storage-security-${var.random_suffix}"
  location = var.location
}

module "storage_account" {
  source = "../../../"

  name                     = "stgsecurity${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Security features
  enable_https_traffic_only        = true
  minimum_tls_version              = "TLS1_2"
  allow_blob_public_access         = false
  enable_infrastructure_encryption = true

  # Advanced security
  advanced_threat_protection_enabled = true

  # Encryption configuration
  encryption_config = {
    key_source                       = "Microsoft.Storage"
    enable_infrastructure_encryption = true
    services = {
      blob = {
        enabled  = true
        key_type = "Account"
      }
      file = {
        enabled  = true
        key_type = "Account"
      }
      table = {
        enabled  = true
        key_type = "Account"
      }
      queue = {
        enabled  = true
        key_type = "Account"
      }
    }
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
    bypass         = "None"
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
  value = module.storage_account.identity_principal_id
}