/**
 * # Azure Route Table Module
 *
 * This module creates and manages an Azure Route Table with support for custom routes and subnet associations.
 *
 * ## Features
 *
 * - ✅ Custom route configuration with next hop types
 * - ✅ BGP route propagation control
 * - ✅ Dynamic subnet associations
 * - ✅ Support for all Azure next hop types
 * - ✅ Comprehensive input validation
 * - ✅ Security-first configuration
 *
 * ## Usage
 *
 * ```hcl
 * module "route_table" {
 *   source = "../../"
 *
 *   name                = "rt-hub-prod-001"
 *   resource_group_name = azurerm_resource_group.example.name
 *   location            = azurerm_resource_group.example.location
 *
 *   disable_bgp_route_propagation = true
 *
 *   routes = [
 *     {
 *       name                   = "to-firewall"
 *       address_prefix         = "10.0.0.0/16"
 *       next_hop_type          = "VirtualAppliance"
 *       next_hop_in_ip_address = "10.1.0.4"
 *     },
 *     {
 *       name           = "to-internet"
 *       address_prefix = "0.0.0.0/0"
 *       next_hop_type  = "Internet"
 *     }
 *   ]
 *
 *   subnet_ids_to_associate = {
 *     (azurerm_subnet.example.id) = azurerm_subnet.example.id
 *   }
 *
 *   tags = {
 *     Environment = "Production"
 *     ManagedBy   = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Examples
 *
 * - [Basic](examples/basic) - Simple route table with basic routes
 * - [Complete](examples/complete) - Full configuration with all features
 * - [Hub-Spoke](examples/hub-spoke) - Route table for hub-spoke network topology
 * - [Firewall](examples/firewall) - Route table for firewall scenarios
 */

locals {
  subnet_associations = { for subnet_id in var.subnet_ids_to_associate : basename(subnet_id) => subnet_id }
}

# Azure Route Table Module
resource "azurerm_route_table" "route_table" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled
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

# Subnet Route Table Associations
resource "azurerm_subnet_route_table_association" "associations" {
  for_each = local.subnet_associations

  subnet_id      = each.value
  route_table_id = azurerm_route_table.route_table.id
}