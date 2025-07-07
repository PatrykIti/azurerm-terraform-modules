# ==============================================================================
# Replication Automation using Azure Logic App
# ==============================================================================

# Storage Account for Function/Logic App
resource "azurerm_storage_account" "replication_app" {
  count                    = var.enable_replication_automation ? 1 : 0
  name                     = "strepapp${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.primary.name
  location                 = azurerm_resource_group.primary.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = merge(var.tags, {
    Purpose = "ReplicationAutomation"
  })
}

# App Service Plan for Logic App
resource "azurerm_service_plan" "replication" {
  count               = var.enable_replication_automation ? 1 : 0
  name                = "asp-replication-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  os_type             = "Windows"
  sku_name            = "WS1"

  tags = merge(var.tags, {
    Purpose = "ReplicationAutomation"
  })
}

# Logic App for Replication Orchestration
resource "azurerm_logic_app_standard" "replication" {
  count                      = var.enable_replication_automation ? 1 : 0
  name                       = "logic-replication-${random_string.suffix.result}"
  location                   = azurerm_resource_group.primary.location
  resource_group_name        = azurerm_resource_group.primary.name
  app_service_plan_id        = azurerm_service_plan.replication[0].id
  storage_account_name       = azurerm_storage_account.replication_app[0].name
  storage_account_access_key = azurerm_storage_account.replication_app[0].primary_access_key

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~14"

    # Storage account connections
    "PRIMARY_STORAGE_CONNECTION"   = module.primary_storage.primary_connection_string
    "SECONDARY_STORAGE_CONNECTION" = module.secondary_storage.primary_connection_string
    "DR_STORAGE_CONNECTION"        = module.dr_storage.primary_connection_string
    "METADATA_STORAGE_CONNECTION"  = module.replication_metadata.primary_connection_string

    # Replication configuration
    "REPLICATION_SCHEDULE"       = var.replication_schedule
    "REPLICATION_BATCH_SIZE"     = "100"
    "REPLICATION_PARALLEL_TASKS" = "10"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Purpose = "ReplicationOrchestration"
  })
}

# Grant Logic App access to storage accounts
resource "azurerm_role_assignment" "logic_app_primary" {
  count                = var.enable_replication_automation ? 1 : 0
  scope                = module.primary_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_logic_app_standard.replication[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "logic_app_secondary" {
  count                = var.enable_replication_automation ? 1 : 0
  scope                = module.secondary_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_logic_app_standard.replication[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "logic_app_dr" {
  count                = var.enable_replication_automation ? 1 : 0
  scope                = module.dr_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_logic_app_standard.replication[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "logic_app_metadata" {
  count                = var.enable_replication_automation ? 1 : 0
  scope                = module.replication_metadata.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_logic_app_standard.replication[0].identity[0].principal_id
}

# ==============================================================================
# Alternative: Azure Function for Replication (Commented Out)
# ==============================================================================

# Uncomment below to use Azure Function instead of Logic App

# resource "azurerm_linux_function_app" "replication" {
#   count                      = var.enable_replication_automation ? 1 : 0
#   name                       = "func-replication-${random_string.suffix.result}"
#   resource_group_name        = azurerm_resource_group.primary.name
#   location                   = azurerm_resource_group.primary.location
#   storage_account_name       = azurerm_storage_account.replication_app[0].name
#   storage_account_access_key = azurerm_storage_account.replication_app[0].primary_access_key
#   service_plan_id            = azurerm_service_plan.replication[0].id
#
#   site_config {
#     application_stack {
#       python_version = "3.9"
#     }
#   }
#
#   app_settings = {
#     "FUNCTIONS_WORKER_RUNTIME"     = "python"
#     "AzureWebJobsStorage"          = azurerm_storage_account.replication_app[0].primary_connection_string
#     
#     # Storage account connections
#     "PRIMARY_STORAGE_CONNECTION"   = module.primary_storage.primary_connection_string
#     "SECONDARY_STORAGE_CONNECTION" = module.secondary_storage.primary_connection_string
#     "DR_STORAGE_CONNECTION"        = module.dr_storage.primary_connection_string
#     "METADATA_STORAGE_CONNECTION"  = module.replication_metadata.primary_connection_string
#     
#     # Replication configuration
#     "REPLICATION_SCHEDULE"         = var.replication_schedule
#     "REPLICATION_BATCH_SIZE"       = "100"
#     "REPLICATION_PARALLEL_TASKS"   = "10"
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   tags = merge(var.tags, {
#     Purpose = "ReplicationFunction"
#   })
# }

# ==============================================================================
# Sample Replication Logic (Documentation)
# ==============================================================================

# The replication automation would implement the following logic:
#
# 1. Timer Trigger (based on REPLICATION_SCHEDULE)
# 2. List blobs in primary storage that have been modified since last sync
# 3. Check metadata storage for last sync timestamp
# 4. Copy new/modified blobs to secondary and DR storage
# 5. Update metadata with sync status and timestamps
# 6. Send alerts if replication lag exceeds threshold
# 7. Handle failures with retry logic and dead letter queue
#
# Key Features:
# - Incremental replication based on blob metadata
# - Parallel processing for improved performance
# - Configurable batch sizes
# - Error handling and retry logic
# - Progress tracking in metadata storage
# - Monitoring integration