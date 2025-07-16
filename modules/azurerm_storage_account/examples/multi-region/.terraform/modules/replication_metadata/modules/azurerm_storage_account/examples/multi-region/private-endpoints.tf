# ==============================================================================
# Private Endpoints for Storage Accounts
# ==============================================================================

# Primary Storage Private Endpoint
resource "azurerm_private_endpoint" "primary_blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.primary_storage.name}-blob"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  subnet_id           = azurerm_subnet.primary_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.primary_storage.name}-blob"
    private_connection_resource_id = module.primary_storage.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.primary_storage.name
    Service        = "blob"
  })
}

# Primary Storage Table Private Endpoint (for metadata)
resource "azurerm_private_endpoint" "primary_table" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.primary_storage.name}-table"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  subnet_id           = azurerm_subnet.primary_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.primary_storage.name}-table"
    private_connection_resource_id = module.primary_storage.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-table"
    private_dns_zone_ids = [azurerm_private_dns_zone.table[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.primary_storage.name
    Service        = "table"
  })
}

# Secondary Storage Private Endpoint
resource "azurerm_private_endpoint" "secondary_blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.secondary_storage.name}-blob"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  subnet_id           = azurerm_subnet.secondary_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.secondary_storage.name}-blob"
    private_connection_resource_id = module.secondary_storage.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.secondary_storage.name
    Service        = "blob"
  })
}

# DR Storage Private Endpoint
resource "azurerm_private_endpoint" "dr_blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.dr_storage.name}-blob"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  subnet_id           = azurerm_subnet.dr_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.dr_storage.name}-blob"
    private_connection_resource_id = module.dr_storage.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.dr_storage.name
    Service        = "blob"
  })
}

# Replication Metadata Storage Private Endpoints
resource "azurerm_private_endpoint" "metadata_blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.replication_metadata.name}-blob"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  subnet_id           = azurerm_subnet.primary_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.replication_metadata.name}-blob"
    private_connection_resource_id = module.replication_metadata.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.replication_metadata.name
    Service        = "blob"
  })
}

resource "azurerm_private_endpoint" "metadata_table" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.replication_metadata.name}-table"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  subnet_id           = azurerm_subnet.primary_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.replication_metadata.name}-table"
    private_connection_resource_id = module.replication_metadata.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-table"
    private_dns_zone_ids = [azurerm_private_dns_zone.table[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.replication_metadata.name
    Service        = "table"
  })
}

resource "azurerm_private_endpoint" "metadata_queue" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-${module.replication_metadata.name}-queue"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  subnet_id           = azurerm_subnet.primary_endpoints[0].id

  private_service_connection {
    name                           = "psc-${module.replication_metadata.name}-queue"
    private_connection_resource_id = module.replication_metadata.id
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-queue"
    private_dns_zone_ids = [azurerm_private_dns_zone.queue[0].id]
  }

  tags = merge(var.tags, {
    StorageAccount = module.replication_metadata.name
    Service        = "queue"
  })
}