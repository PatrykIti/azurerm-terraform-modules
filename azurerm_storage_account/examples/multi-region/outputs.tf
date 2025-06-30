output "primary_storage" {
  description = "Primary region storage account details"
  value = {
    id                 = module.primary_storage.id
    name               = module.primary_storage.name
    location           = module.primary_storage.primary_location
    secondary_location = module.primary_storage.secondary_location
    blob_endpoint      = module.primary_storage.primary_blob_endpoint
    secondary_endpoint = module.primary_storage.secondary_blob_endpoint
  }
}

output "secondary_storage" {
  description = "Secondary region storage account details"
  value = {
    id            = module.secondary_storage.id
    name          = module.secondary_storage.name
    location      = module.secondary_storage.primary_location
    blob_endpoint = module.secondary_storage.primary_blob_endpoint
  }
}

output "dr_storage" {
  description = "Disaster recovery storage account details"
  value = {
    id            = module.dr_storage.id
    name          = module.dr_storage.name
    location      = module.dr_storage.primary_location
    blob_endpoint = module.dr_storage.primary_blob_endpoint
  }
}

output "replication_metadata_storage" {
  description = "Replication metadata storage account details"
  value = {
    id             = module.replication_metadata.id
    name           = module.replication_metadata.name
    table_endpoint = module.replication_metadata.primary_table_endpoint
    queue_endpoint = module.replication_metadata.primary_queue_endpoint
  }
}

output "log_analytics_workspace_id" {
  description = "Shared Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.shared.id
}

output "storage_account_identities" {
  description = "Managed identities for all storage accounts"
  value = {
    primary   = module.primary_storage.identity.principal_id
    secondary = module.secondary_storage.identity.principal_id
    dr        = module.dr_storage.identity.principal_id
    metadata  = module.replication_metadata.identity.principal_id
  }
}

output "region_mapping" {
  description = "Mapping of storage accounts to regions"
  value = {
    "West Europe"  = module.primary_storage.name
    "North Europe" = module.secondary_storage.name
    "UK South"     = module.dr_storage.name
  }
}

output "replication_endpoints" {
  description = "Endpoints for setting up cross-region replication"
  value = {
    source_primary      = module.primary_storage.primary_blob_endpoint
    source_secondary    = module.primary_storage.secondary_blob_endpoint
    target_secondary    = module.secondary_storage.primary_blob_endpoint
    target_dr           = module.dr_storage.primary_blob_endpoint
    metadata_table      = module.replication_metadata.primary_table_endpoint
    metadata_queue      = module.replication_metadata.primary_queue_endpoint
  }
}