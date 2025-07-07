# ==============================================================================
# Network Security Groups and Rules
# ==============================================================================

# NSG for Private Endpoints Subnet
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "nsg-private-endpoints"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Deny all inbound traffic by default (private endpoints handle their own traffic)
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# NSG for Application Subnet
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Allow HTTPS outbound to storage endpoints
  security_rule {
    name                       = "AllowStorageHTTPS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage"
  }

  # Deny all other outbound traffic
  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# ==============================================================================
# Network Watcher and Flow Logs
# ==============================================================================

# Network Watcher (if not exists)
resource "azurerm_network_watcher" "example" {
  count               = var.enable_network_watcher ? 1 : 0
  name                = "nw-${var.location}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}

# Storage Account for NSG Flow Logs
resource "azurerm_storage_account" "flow_logs" {
  count                    = var.enable_network_flow_logs ? 1 : 0
  name                     = "stflowlogs${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = merge(var.tags, {
    Purpose = "NSGFlowLogs"
  })
}

# NSG Flow Logs for Private Endpoints NSG
resource "azurerm_network_watcher_flow_log" "private_endpoints" {
  count                = var.enable_network_flow_logs ? 1 : 0
  name                 = "flowlog-nsg-private-endpoints"
  network_watcher_name = var.enable_network_watcher ? azurerm_network_watcher.example[0].name : "NetworkWatcher_${var.location}"
  resource_group_name  = var.enable_network_watcher ? azurerm_resource_group.example.name : "NetworkWatcherRG"
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
  storage_account_id        = azurerm_storage_account.flow_logs[0].id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.example.location
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    interval_in_minutes   = 10
  }

  tags = var.tags
}

# NSG Flow Logs for App NSG
resource "azurerm_network_watcher_flow_log" "app" {
  count                = var.enable_network_flow_logs ? 1 : 0
  name                 = "flowlog-nsg-app"
  network_watcher_name = var.enable_network_watcher ? azurerm_network_watcher.example[0].name : "NetworkWatcher_${var.location}"
  resource_group_name  = var.enable_network_watcher ? azurerm_resource_group.example.name : "NetworkWatcherRG"
  network_security_group_id = azurerm_network_security_group.app.id
  storage_account_id        = azurerm_storage_account.flow_logs[0].id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.example.location
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    interval_in_minutes   = 10
  }

  tags = var.tags
}

# ==============================================================================
# DDoS Protection Plan (Optional due to cost)
# ==============================================================================

resource "azurerm_network_ddos_protection_plan" "example" {
  count               = var.enable_ddos_protection ? 1 : 0
  name                = "ddos-${var.resource_prefix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}