# Azure Route Table Module
# Manages route tables with custom routes and BGP propagation.
# Subnet associations are intentionally managed outside the module.

locals {
  bgp_route_propagation_enabled = var.disable_bgp_route_propagation == null ? var.bgp_route_propagation_enabled : !var.disable_bgp_route_propagation
}

# Azure Route Table Module
resource "azurerm_route_table" "route_table" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = local.bgp_route_propagation_enabled
  tags                          = var.tags
}

# Custom Routes
resource "azurerm_route" "routes" {
  for_each = { for route in var.routes : route.name => route }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}
