terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-adv-${var.random_suffix}"
  location = var.location
}

locals {
  # SAS Policy
  sas_policy = {
    expiration_period = "P30D"
    expiration_action = "Log"
  }

  # Routing preferences
  routing = {
    choice                      = "InternetRouting"
    publish_internet_endpoints  = true
    publish_microsoft_endpoints = false
  }

  # Share properties with SMB settings
  share_properties = {
    cors_rule = [
      {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "POST"]
        allowed_origins    = ["https://test.example.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    ]

    retention_policy = {
      days = 7
    }

    smb = {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["NTLMv2"]
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = ["AES-128-GCM", "AES-256-GCM"]
      multichannel_enabled            = true
    }
  }
}

module "storage_account" {
  source = "../../.."

  name                     = "dpcadv${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Advanced policies
  sas_policy       = local.sas_policy
  routing          = local.routing
  share_properties = local.share_properties

  # Enable features
  is_hns_enabled = true
  sftp_enabled   = true

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true
    allow_nested_items_to_be_public = false
  }

  # Blob properties
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true

    delete_retention_policy = {
      enabled = true
      days    = 7
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 7
    }
  }

  # Simple lifecycle rule for testing
  lifecycle_rules = [
    {
      name    = "test-rule"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["test/"]
      }

      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than = 30
          delete_after_days_since_modification_greater_than       = 90
        }
      }
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "AdvancedPolicies"
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

output "primary_blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}

output "sftp_enabled" {
  value = module.storage_account.sftp_enabled
}

output "is_hns_enabled" {
  value = module.storage_account.is_hns_enabled
}