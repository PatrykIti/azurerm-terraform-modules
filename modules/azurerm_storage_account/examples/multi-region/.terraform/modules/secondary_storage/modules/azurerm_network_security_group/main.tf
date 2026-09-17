# Azure Network Security Group Module
# This module creates an Azure Network Security Group with comprehensive security rules configuration

# Main Network Security Group resource
resource "azurerm_network_security_group" "network_security_group" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# Security Rules
resource "azurerm_network_security_rule" "security_rules" {
  for_each = { for rule in var.security_rules : rule.name => rule }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  description                 = try(each.value.description, null)
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group.name

  # Handle mutually exclusive source port attributes
  source_port_range  = try(each.value.source_port_range, null)
  source_port_ranges = try(each.value.source_port_ranges, null)

  # Handle mutually exclusive destination port attributes
  destination_port_range  = try(each.value.destination_port_range, null)
  destination_port_ranges = try(each.value.destination_port_ranges, null)

  # Handle mutually exclusive source address attributes
  source_address_prefix                 = try(each.value.source_address_prefix, null)
  source_address_prefixes               = try(each.value.source_address_prefixes, null)
  source_application_security_group_ids = try(each.value.source_application_security_group_ids, null)

  # Handle mutually exclusive destination address attributes
  destination_address_prefix                 = try(each.value.destination_address_prefix, null)
  destination_address_prefixes               = try(each.value.destination_address_prefixes, null)
  destination_application_security_group_ids = try(each.value.destination_application_security_group_ids, null)
}

