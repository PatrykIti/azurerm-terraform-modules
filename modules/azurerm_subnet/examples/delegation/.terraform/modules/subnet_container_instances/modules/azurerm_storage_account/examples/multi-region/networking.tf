# ==============================================================================
# Networking Infrastructure for Multi-Region Storage
# ==============================================================================

# Primary Region VNet
resource "azurerm_virtual_network" "primary" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "vnet-${var.resource_prefix}-primary"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  address_space       = ["10.0.0.0/16"]

  tags = merge(var.tags, {
    Region = "Primary"
  })
}

# Subnet for Private Endpoints in Primary Region
resource "azurerm_subnet" "primary_endpoints" {
  count                = var.enable_private_endpoints ? 1 : 0
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.primary[0].name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# Secondary Region VNet
resource "azurerm_virtual_network" "secondary" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "vnet-${var.resource_prefix}-secondary"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  address_space       = ["10.1.0.0/16"]

  tags = merge(var.tags, {
    Region = "Secondary"
  })
}

# Subnet for Private Endpoints in Secondary Region
resource "azurerm_subnet" "secondary_endpoints" {
  count                = var.enable_private_endpoints ? 1 : 0
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.secondary.name
  virtual_network_name = azurerm_virtual_network.secondary[0].name
  address_prefixes     = ["10.1.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# DR Region VNet
resource "azurerm_virtual_network" "dr" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "vnet-${var.resource_prefix}-dr"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  address_space       = ["10.2.0.0/16"]

  tags = merge(var.tags, {
    Region = "DR"
  })
}

# Subnet for Private Endpoints in DR Region
resource "azurerm_subnet" "dr_endpoints" {
  count                = var.enable_private_endpoints ? 1 : 0
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.dr.name
  virtual_network_name = azurerm_virtual_network.dr[0].name
  address_prefixes     = ["10.2.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# ==============================================================================
# VNet Peering for Cross-Region Connectivity
# ==============================================================================

# Primary to Secondary Peering
resource "azurerm_virtual_network_peering" "primary_to_secondary" {
  count                        = var.enable_private_endpoints ? 1 : 0
  name                         = "peer-primary-to-secondary"
  resource_group_name          = azurerm_resource_group.primary.name
  virtual_network_name         = azurerm_virtual_network.primary[0].name
  remote_virtual_network_id    = azurerm_virtual_network.secondary[0].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Secondary to Primary Peering
resource "azurerm_virtual_network_peering" "secondary_to_primary" {
  count                        = var.enable_private_endpoints ? 1 : 0
  name                         = "peer-secondary-to-primary"
  resource_group_name          = azurerm_resource_group.secondary.name
  virtual_network_name         = azurerm_virtual_network.secondary[0].name
  remote_virtual_network_id    = azurerm_virtual_network.primary[0].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Primary to DR Peering
resource "azurerm_virtual_network_peering" "primary_to_dr" {
  count                        = var.enable_private_endpoints ? 1 : 0
  name                         = "peer-primary-to-dr"
  resource_group_name          = azurerm_resource_group.primary.name
  virtual_network_name         = azurerm_virtual_network.primary[0].name
  remote_virtual_network_id    = azurerm_virtual_network.dr[0].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# DR to Primary Peering
resource "azurerm_virtual_network_peering" "dr_to_primary" {
  count                        = var.enable_private_endpoints ? 1 : 0
  name                         = "peer-dr-to-primary"
  resource_group_name          = azurerm_resource_group.dr.name
  virtual_network_name         = azurerm_virtual_network.dr[0].name
  remote_virtual_network_id    = azurerm_virtual_network.primary[0].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ==============================================================================
# Private DNS Zones for Storage Services
# ==============================================================================

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.primary.name

  tags = var.tags
}

# Link DNS Zone to Primary VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_primary" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "blob-dns-primary"
  resource_group_name   = azurerm_resource_group.primary.name
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = azurerm_virtual_network.primary[0].id
}

# Link DNS Zone to Secondary VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_secondary" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "blob-dns-secondary"
  resource_group_name   = azurerm_resource_group.primary.name
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = azurerm_virtual_network.secondary[0].id
}

# Link DNS Zone to DR VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_dr" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "blob-dns-dr"
  resource_group_name   = azurerm_resource_group.primary.name
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = azurerm_virtual_network.dr[0].id
}

# Private DNS Zone for Table Storage
resource "azurerm_private_dns_zone" "table" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.primary.name

  tags = var.tags
}

# Link Table DNS Zone to Primary VNet
resource "azurerm_private_dns_zone_virtual_network_link" "table_primary" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "table-dns-primary"
  resource_group_name   = azurerm_resource_group.primary.name
  private_dns_zone_name = azurerm_private_dns_zone.table[0].name
  virtual_network_id    = azurerm_virtual_network.primary[0].id
}

# Private DNS Zone for Queue Storage
resource "azurerm_private_dns_zone" "queue" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.primary.name

  tags = var.tags
}

# Link Queue DNS Zone to Primary VNet
resource "azurerm_private_dns_zone_virtual_network_link" "queue_primary" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "queue-dns-primary"
  resource_group_name   = azurerm_resource_group.primary.name
  private_dns_zone_name = azurerm_private_dns_zone.queue[0].name
  virtual_network_id    = azurerm_virtual_network.primary[0].id
}