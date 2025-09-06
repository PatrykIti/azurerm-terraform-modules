terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-advanced-policies-example"
  location = "West Europe"
}

# Define locals for complex policies
locals {
  # SAS Policy - Shared Access Signatures expire after 30 days
  sas_policy = {
    expiration_period = "P30D" # ISO 8601 duration format - 30 days
    expiration_action = "Log"  # Log when SAS tokens expire
  }

  # Immutability Policy - WORM (Write Once Read Many) compliance
  immutability_policy = {
    allow_protected_append_writes = true
    state                         = "Unlocked" # Can be "Unlocked", "Locked", or "Disabled"
    period_since_creation_in_days = 7          # Immutability period
  }

  # Routing preferences - Choose between Microsoft network or Internet routing
  routing = {
    choice                      = "InternetRouting" # or "MicrosoftRouting"
    publish_internet_endpoints  = true
    publish_microsoft_endpoints = false
  }

  # Custom domain configuration
  # WARNING: Manual DNS CNAME record creation is required for this custom domain to validate.
  # The CNAME record must point from your custom domain to the storage account's blob endpoint.
  # Without the DNS record, Terraform apply will fail with a validation error.
  custom_domain = {
    name          = "storage.example.com" # Your custom domain
    use_subdomain = false                 # Set to true for indirect CNAME validation
  }

  # Share properties with SMB settings
  share_properties = {
    # CORS rules for file shares
    cors_rule = [
      {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "POST", "PUT"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    ]

    # Retention policy for file share snapshots
    retention_policy = {
      days = 30 # Keep snapshots for 30 days
    }

    # SMB protocol settings
    smb = {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["NTLMv2", "Kerberos"]
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = ["AES-128-GCM", "AES-256-GCM"]
      multichannel_enabled            = true # Enable SMB Multichannel for better performance
    }
  }
}

# Storage Account with Advanced Policies
module "storage_account" {
  source = "../../"

  # Basic configuration
  name                     = "stadvancedpoliciesex"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Advanced policies
  sas_policy          = local.sas_policy
  immutability_policy = local.immutability_policy
  routing             = local.routing
  custom_domain       = local.custom_domain
  share_properties    = local.share_properties

  # Enable features for demonstration
  is_hns_enabled     = true # Enable Data Lake Gen2
  sftp_enabled       = true # Enable SFTP
  local_user_enabled = true # Enable local users for SFTP

  # Enhanced security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true # Required for SAS policies
    allow_nested_items_to_be_public = false
  }

  # Enable versioning and soft delete for blobs
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    default_service_version  = "2023-11-03"

    delete_retention_policy = {
      enabled = true
      days    = 30
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 30
    }

    restore_policy = {
      enabled = true
      days    = 29 # Must be less than delete_retention_policy.days
    }
  }

  # Lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      name    = "archive-old-data"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = []
      }

      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 30
          tier_to_archive_after_days_since_modification_greater_than = 90
          delete_after_days_since_modification_greater_than          = 365
        }

        snapshot = {
          change_tier_to_cool_after_days_since_creation    = 30
          change_tier_to_archive_after_days_since_creation = 90
          delete_after_days_since_creation_greater_than    = 180
        }
      }
    }
  ]

  tags = {
    Environment = "Example"
    Purpose     = "Advanced Policies Demo"
    Compliance  = "WORM-Enabled"
  }
}