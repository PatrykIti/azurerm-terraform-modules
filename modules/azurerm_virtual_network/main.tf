# Terraform Azure Virtual Network Module
# Manages Azure Virtual Network with comprehensive configuration options

# Main Virtual Network Resource
resource "azurerm_virtual_network" "virtual_network" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space

  # DNS Configuration
  dns_servers = var.dns_servers

  # Network Flow Configuration
  flow_timeout_in_minutes = var.flow_timeout_in_minutes

  # BGP Community (for ExpressRoute)
  bgp_community = var.bgp_community

  # Edge Zone
  edge_zone = var.edge_zone

  # DDoS Protection Plan
  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []
    content {
      id     = ddos_protection_plan.value.id
      enable = ddos_protection_plan.value.enable
    }
  }

  # Encryption Configuration
  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      enforcement = encryption.value.enforcement
    }
  }

  tags = var.tags

  # lifecycle {
  #   # Prevent destruction of VNet if it contains subnets
  #   # Note: prevent_destroy must be a literal value, not a variable
  #   prevent_destroy = true
  # }
}

# Virtual Network Peerings
resource "azurerm_virtual_network_peering" "peering" {
  for_each = { for peering in var.peerings : peering.name => peering }

  name                         = each.value.name
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.virtual_network.name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways

  # Triggers for recreation when peering configuration changes
  triggers = each.value.triggers

  depends_on = [azurerm_virtual_network.virtual_network]
}

# Network Watcher Flow Logs (if enabled)
resource "azurerm_network_watcher_flow_log" "flow_log" {
  count = var.flow_log != null ? 1 : 0

  network_watcher_name = var.flow_log.network_watcher_name
  resource_group_name  = var.flow_log.network_watcher_resource_group_name
  name                 = "${var.name}-flowlog"
  target_resource_id   = var.flow_log.network_security_group_id
  storage_account_id   = var.flow_log.storage_account_id
  enabled              = var.flow_log.enabled
  version              = var.flow_log.version

  dynamic "retention_policy" {
    for_each = var.flow_log.retention_policy != null ? [var.flow_log.retention_policy] : []
    content {
      enabled = retention_policy.value.enabled
      days    = retention_policy.value.days
    }
  }

  dynamic "traffic_analytics" {
    for_each = var.flow_log.traffic_analytics != null ? [var.flow_log.traffic_analytics] : []
    content {
      enabled               = traffic_analytics.value.enabled
      workspace_id          = traffic_analytics.value.workspace_id
      workspace_region      = traffic_analytics.value.workspace_region
      workspace_resource_id = traffic_analytics.value.workspace_resource_id
      interval_in_minutes   = traffic_analytics.value.interval_in_minutes
    }
  }

  tags = var.tags

  depends_on = [azurerm_virtual_network.virtual_network]
}

# Private DNS Zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  for_each = { for link in var.private_dns_zone_links : link.name => link }

  name                  = each.value.name
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.value.private_dns_zone_name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
  registration_enabled  = each.value.registration_enabled

  tags = merge(var.tags, each.value.tags)

  depends_on = [azurerm_virtual_network.virtual_network]
}

# Diagnostic Settings for Virtual Network
resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  count = var.diagnostic_settings.enabled ? 1 : 0

  name                           = "${var.name}-diag"
  target_resource_id             = azurerm_virtual_network.virtual_network.id
  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_auth_rule_id

  # Virtual Network Logs
  dynamic "enabled_log" {
    for_each = {
      for k, v in {
        "VMProtectionAlerts" = var.diagnostic_settings.logs.vm_protection_alerts
      } : k => v if v
    }
    content {
      category = enabled_log.key
    }
  }

  # Virtual Network Metrics
  dynamic "enabled_metric" {
    for_each = {
      for k, v in {
        "AllMetrics" = var.diagnostic_settings.metrics.all_metrics
      } : k => v if v
    }
    content {
      category = enabled_metric.key
    }
  }

  depends_on = [azurerm_virtual_network.virtual_network]
}