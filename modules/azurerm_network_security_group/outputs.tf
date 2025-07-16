output "id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.network_security_group.id
}

output "name" {
  description = "The name of the Network Security Group"
  value       = azurerm_network_security_group.network_security_group.name
}

output "location" {
  description = "The location of the Network Security Group"
  value       = azurerm_network_security_group.network_security_group.location
}

output "resource_group_name" {
  description = "The name of the resource group containing the Network Security Group"
  value       = azurerm_network_security_group.network_security_group.resource_group_name
}

output "tags" {
  description = "The tags assigned to the Network Security Group"
  value       = azurerm_network_security_group.network_security_group.tags
}

# Security Rules Output
output "security_rule_ids" {
  description = "Map of security rule names to their resource IDs"
  value = {
    for rule_name, rule in azurerm_network_security_rule.security_rules : 
      rule_name => rule.id
  }
}

output "security_rules" {
  description = "Map of security rule names to their full configuration"
  value = {
    for rule_name, rule in azurerm_network_security_rule.security_rules : 
      rule_name => {
        id                         = rule.id
        priority                   = rule.priority
        direction                  = rule.direction
        access                     = rule.access
        protocol                   = rule.protocol
        source_port_range          = rule.source_port_range
        source_port_ranges         = rule.source_port_ranges
        destination_port_range     = rule.destination_port_range
        destination_port_ranges    = rule.destination_port_ranges
        source_address_prefix      = rule.source_address_prefix
        source_address_prefixes    = rule.source_address_prefixes
        destination_address_prefix = rule.destination_address_prefix
        destination_address_prefixes = rule.destination_address_prefixes
        description                = rule.description
      }
  }
}

# Flow Log Output
output "flow_log_id" {
  description = "The ID of the NSG Flow Log resource (if enabled)"
  value       = var.flow_log_enabled ? azurerm_network_watcher_flow_log.flow_log[0].id : null
}

output "flow_log_enabled" {
  description = "Whether NSG Flow Logs are enabled"
  value       = var.flow_log_enabled
}

output "traffic_analytics_enabled" {
  description = "Whether Traffic Analytics is enabled for the flow logs"
  value       = var.traffic_analytics_enabled
}