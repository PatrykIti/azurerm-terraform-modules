# Virtual Network Core Outputs
output "id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.id
}

output "name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.name
}

output "location" {
  description = "The Azure Region where the Virtual Network exists."
  value       = azurerm_virtual_network.virtual_network.location
}

output "resource_group_name" {
  description = "The name of the resource group containing the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.resource_group_name
}

output "address_space" {
  description = "The address space of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.address_space
}

output "dns_servers" {
  description = "The DNS servers configured for the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.dns_servers
}

output "guid" {
  description = "The GUID of the Virtual Network."
  value       = azurerm_virtual_network.virtual_network.guid
}

# Subnet Information
output "subnet" {
  description = "Information about subnets defined within the Virtual Network (if any)."
  value       = azurerm_virtual_network.virtual_network.subnet
}

# Peering Outputs
output "peerings" {
  description = "Information about Virtual Network peerings."
  value = {
    for name, peering in azurerm_virtual_network_peering.peering : name => {
      id                           = peering.id
      name                         = peering.name
      remote_virtual_network_id    = peering.remote_virtual_network_id
      allow_virtual_network_access = peering.allow_virtual_network_access
      allow_forwarded_traffic      = peering.allow_forwarded_traffic
      allow_gateway_transit        = peering.allow_gateway_transit
      use_remote_gateways          = peering.use_remote_gateways
    }
  }
}

# Flow Log Outputs
output "flow_log" {
  description = "Information about Network Watcher Flow Log (if configured)."
  value = var.flow_log != null ? {
    id                 = try(azurerm_network_watcher_flow_log.flow_log[0].id, null)
    name               = try(azurerm_network_watcher_flow_log.flow_log[0].name, null)
    enabled            = try(azurerm_network_watcher_flow_log.flow_log[0].enabled, null)
    version            = try(azurerm_network_watcher_flow_log.flow_log[0].version, null)
    storage_account_id = try(azurerm_network_watcher_flow_log.flow_log[0].storage_account_id, null)
  } : null
}

# Private DNS Zone Links Outputs
output "private_dns_zone_links" {
  description = "Information about Private DNS Zone Virtual Network Links."
  value = {
    for name, link in azurerm_private_dns_zone_virtual_network_link.dns_zone_link : name => {
      id                    = link.id
      name                  = link.name
      private_dns_zone_name = link.private_dns_zone_name
      virtual_network_id    = link.virtual_network_id
      registration_enabled  = link.registration_enabled
    }
  }
}

# Diagnostic Settings Output
output "diagnostic_setting" {
  description = "Information about diagnostic settings (if configured)."
  value = var.diagnostic_settings.enabled ? {
    id                             = try(azurerm_monitor_diagnostic_setting.diagnostic_setting[0].id, null)
    name                           = try(azurerm_monitor_diagnostic_setting.diagnostic_setting[0].name, null)
    target_resource_id             = try(azurerm_monitor_diagnostic_setting.diagnostic_setting[0].target_resource_id, null)
    log_analytics_workspace_id     = try(azurerm_monitor_diagnostic_setting.diagnostic_setting[0].log_analytics_workspace_id, null)
    storage_account_id             = try(azurerm_monitor_diagnostic_setting.diagnostic_setting[0].storage_account_id, null)
    eventhub_authorization_rule_id = try(azurerm_monitor_diagnostic_setting.diagnostic_setting[0].eventhub_authorization_rule_id, null)
  } : null
}

# Network Configuration Summary
output "network_configuration" {
  description = "Summary of Virtual Network configuration."
  value = {
    name                    = azurerm_virtual_network.virtual_network.name
    id                      = azurerm_virtual_network.virtual_network.id
    address_space           = azurerm_virtual_network.virtual_network.address_space
    dns_servers             = azurerm_virtual_network.virtual_network.dns_servers
    flow_timeout_in_minutes = azurerm_virtual_network.virtual_network.flow_timeout_in_minutes
    bgp_community           = azurerm_virtual_network.virtual_network.bgp_community
    edge_zone               = azurerm_virtual_network.virtual_network.edge_zone
    ddos_protection_enabled = var.ddos_protection_plan != null ? var.ddos_protection_plan.enable : false
    encryption_enabled      = var.encryption != null
    peerings_count          = length(var.peerings)
    dns_zone_links_count    = length(var.private_dns_zone_links)
  }
}