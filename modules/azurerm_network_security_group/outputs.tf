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
      id                           = rule.id
      name                         = rule.name
      priority                     = rule.priority
      direction                    = rule.direction
      access                       = rule.access
      protocol                     = rule.protocol
      source_port_range            = rule.source_port_range
      source_port_ranges           = rule.source_port_ranges
      destination_port_range       = rule.destination_port_range
      destination_port_ranges      = rule.destination_port_ranges
      source_address_prefix        = rule.source_address_prefix
      source_address_prefixes      = rule.source_address_prefixes
      destination_address_prefix   = rule.destination_address_prefix
      destination_address_prefixes = rule.destination_address_prefixes
      description                  = rule.description
    }
  }
}

output "diagnostic_settings_ids" {
  description = "Map of diagnostic settings names to their resource IDs."
  value = {
    for name, setting in azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings :
    name => setting.id
  }
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no categories were available after filtering."
  value       = local.diagnostic_settings_skipped
}
