output "primary_storage" {
  description = "Primary region storage account details with geo-redundant endpoints"
  value = {
    id                 = module.primary_storage.id
    name               = module.primary_storage.name
    location           = module.primary_storage.primary_location
    secondary_location = module.primary_storage.secondary_location
    replication_type   = module.primary_storage.account_replication_type
    
    # Primary endpoints
    primary_endpoints = {
      blob  = module.primary_storage.primary_blob_endpoint
      queue = module.primary_storage.primary_queue_endpoint
      table = module.primary_storage.primary_table_endpoint
      file  = module.primary_storage.primary_file_endpoint
      web   = module.primary_storage.primary_web_endpoint
      dfs   = module.primary_storage.primary_dfs_endpoint
    }
    
    # Secondary endpoints (geo-redundant)
    secondary_endpoints = {
      blob  = module.primary_storage.secondary_blob_endpoint
      queue = module.primary_storage.secondary_queue_endpoint
      table = module.primary_storage.secondary_table_endpoint
      file  = module.primary_storage.secondary_file_endpoint
      web   = module.primary_storage.secondary_web_endpoint
      dfs   = module.primary_storage.secondary_dfs_endpoint
    }
    
    # Cross-tenant replication status
    cross_tenant_replication_enabled = module.primary_storage.cross_tenant_replication_enabled
  }
}

output "secondary_storage" {
  description = "Secondary region storage account details"
  value = {
    id               = module.secondary_storage.id
    name             = module.secondary_storage.name
    location         = module.secondary_storage.primary_location
    replication_type = module.secondary_storage.account_replication_type
    
    # Endpoints
    endpoints = {
      blob  = module.secondary_storage.primary_blob_endpoint
      queue = module.secondary_storage.primary_queue_endpoint
      table = module.secondary_storage.primary_table_endpoint
      file  = module.secondary_storage.primary_file_endpoint
    }
    
    # Cross-tenant replication status
    cross_tenant_replication_enabled = module.secondary_storage.cross_tenant_replication_enabled
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
  description = "Replication metadata storage account details with geo-redundant endpoints"
  value = {
    id                 = module.replication_metadata.id
    name               = module.replication_metadata.name
    location           = module.replication_metadata.primary_location
    secondary_location = module.replication_metadata.secondary_location
    replication_type   = module.replication_metadata.account_replication_type
    
    # Primary endpoints
    primary_endpoints = {
      table = module.replication_metadata.primary_table_endpoint
      queue = module.replication_metadata.primary_queue_endpoint
      blob  = module.replication_metadata.primary_blob_endpoint
    }
    
    # Secondary endpoints (geo-redundant)
    secondary_endpoints = {
      table = module.replication_metadata.secondary_table_endpoint
      queue = module.replication_metadata.secondary_queue_endpoint
      blob  = module.replication_metadata.secondary_blob_endpoint
    }
    
    # Cross-tenant replication status
    cross_tenant_replication_enabled = module.replication_metadata.cross_tenant_replication_enabled
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
    source_primary   = module.primary_storage.primary_blob_endpoint
    source_secondary = module.primary_storage.secondary_blob_endpoint
    target_secondary = module.secondary_storage.primary_blob_endpoint
    target_dr        = module.dr_storage.primary_blob_endpoint
    metadata_table   = module.replication_metadata.primary_table_endpoint
    metadata_queue   = module.replication_metadata.primary_queue_endpoint
  }
}

output "geo_redundancy_configuration" {
  description = "Comprehensive geo-redundancy configuration across all storage accounts"
  value = {
    primary_gzrs = {
      account_name     = module.primary_storage.name
      replication_type = "GZRS"
      primary_region   = module.primary_storage.primary_location
      secondary_region = module.primary_storage.secondary_location
      failover_ready   = true
      read_access_geo  = true
      zone_redundant   = true
    }
    secondary_zrs = {
      account_name     = module.secondary_storage.name
      replication_type = "ZRS"
      region           = module.secondary_storage.primary_location
      zone_redundant   = true
      role             = "Regional backup with zone redundancy"
    }
    dr_lrs = {
      account_name     = module.dr_storage.name
      replication_type = "LRS"
      region           = module.dr_storage.primary_location
      role             = "Long-term archive (cost-optimized)"
    }
    metadata_ragrs = {
      account_name     = module.replication_metadata.name
      replication_type = "RAGRS"
      primary_region   = module.replication_metadata.primary_location
      secondary_region = module.replication_metadata.secondary_location
      read_access_geo  = true
      role             = "Replication metadata and orchestration"
    }
  }
}

output "cross_tenant_replication_status" {
  description = "Cross-tenant replication configuration for all storage accounts"
  value = {
    enabled_accounts = [
      for storage in [
        module.primary_storage,
        module.secondary_storage,
        module.replication_metadata
      ] : storage.name if storage.cross_tenant_replication_enabled == true
    ]
    configuration = {
      primary_storage    = module.primary_storage.cross_tenant_replication_enabled
      secondary_storage  = module.secondary_storage.cross_tenant_replication_enabled
      metadata_storage   = module.replication_metadata.cross_tenant_replication_enabled
      dr_storage         = false # LRS doesn't support cross-tenant replication
    }
  }
}

output "private_endpoints" {
  description = "Private endpoint configuration when enabled"
  value = var.enable_private_endpoints ? {
    primary_blob_endpoint = {
      id   = azurerm_private_endpoint.primary_blob[0].id
      name = azurerm_private_endpoint.primary_blob[0].name
      ip   = azurerm_private_endpoint.primary_blob[0].private_service_connection[0].private_ip_address
    }
    secondary_blob_endpoint = {
      id   = azurerm_private_endpoint.secondary_blob[0].id
      name = azurerm_private_endpoint.secondary_blob[0].name
      ip   = azurerm_private_endpoint.secondary_blob[0].private_service_connection[0].private_ip_address
    }
    dr_blob_endpoint = {
      id   = azurerm_private_endpoint.dr_blob[0].id
      name = azurerm_private_endpoint.dr_blob[0].name
      ip   = azurerm_private_endpoint.dr_blob[0].private_service_connection[0].private_ip_address
    }
  } : null
}

output "replication_automation" {
  description = "Replication automation configuration when enabled"
  value = var.enable_replication_automation ? {
    logic_app_name = azurerm_logic_app_standard.replication[0].name
    logic_app_id   = azurerm_logic_app_standard.replication[0].id
    schedule       = var.replication_schedule
  } : null
}

output "monitoring_configuration" {
  description = "Monitoring and alerting configuration"
  value = var.enable_monitoring_alerts ? {
    action_group_id      = azurerm_monitor_action_group.replication[0].id
    log_analytics_id     = azurerm_log_analytics_workspace.shared.id
    application_insights = azurerm_application_insights.replication[0].id
    alerts = {
      replication_lag_threshold_minutes = var.replication_lag_threshold_minutes
      primary_availability_alert        = azurerm_monitor_metric_alert.primary_availability[0].name
      replication_lag_alert             = azurerm_monitor_metric_alert.primary_replication_lag[0].name
    }
  } : {
    log_analytics_id = azurerm_log_analytics_workspace.shared.id
  }
}

output "deployment_instructions" {
  description = "Instructions for deploying and configuring the multi-region storage"
  value = <<-EOT
    Multi-Region Storage Deployment Complete!
    
    Next Steps:
    1. Configure private endpoints: terraform apply -var="enable_private_endpoints=true"
    2. Enable replication automation: terraform apply -var="enable_replication_automation=true"
    3. Configure monitoring alerts: terraform apply -var="enable_monitoring_alerts=true"
    
    Testing Failover:
    az storage account failover --name ${module.primary_storage.name} --resource-group ${azurerm_resource_group.primary.name}
    
    Monitoring:
    - Log Analytics Workspace: ${azurerm_log_analytics_workspace.shared.name}
    - View replication lag metrics in Azure Portal
    
    Security Recommendations:
    - Enable private endpoints for production use
    - Configure allowed IP ranges for public access
    - Implement customer-managed keys for encryption
  EOT
}