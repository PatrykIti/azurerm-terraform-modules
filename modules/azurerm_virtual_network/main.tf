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
}




