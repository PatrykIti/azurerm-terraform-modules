locals {
  bgp_route_propagation_enabled = var.disable_bgp_route_propagation == null ? var.bgp_route_propagation_enabled : !var.disable_bgp_route_propagation
}
