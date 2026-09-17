# Alternative solution showing how to handle subnet associations with proper null handling
# This file demonstrates patterns that could be implemented if we wanted to keep associations in the module

# ==============================================================================
# PATTERN 1: If we wanted to add associations back to the route_table module
# ==============================================================================

# This would go in the module's variables.tf:
# variable "subnet_associations" {
#   description = "Map of subnet associations with explicit configuration"
#   type = map(object({
#     subnet_id = string
#     enabled   = optional(bool, true)
#   }))
#   default = {}
# }

# This would go in the module's main.tf:
# resource "azurerm_subnet_route_table_association" "associations" {
#   for_each = {
#     for key, config in var.subnet_associations :
#     key => config
#     if config.enabled && try(config.subnet_id, null) != null
#   }
#
#   subnet_id      = each.value.subnet_id
#   route_table_id = azurerm_route_table.route_table.id
# }

# ==============================================================================
# PATTERN 2: Current recommended approach - associations at the wrapper level
# ==============================================================================

# Example of how to create associations at the wrapper/consumer level
# This avoids the for_each unknown values issue

# Step 1: Create your subnets
# resource "azurerm_subnet" "example" {
#   for_each = var.subnet_configs
#   
#   name                 = each.key
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = [each.value.address_prefix]
# }

# Step 2: Create the route table using the module
# module "route_table" {
#   source = "../"
#
#   name                          = "rt-example"
#   resource_group_name           = azurerm_resource_group.example.name
#   location                      = azurerm_resource_group.example.location
#   bgp_route_propagation_enabled = false
#
#   routes = [
#     {
#       name           = "to-internet"
#       address_prefix = "0.0.0.0/0"
#       next_hop_type  = "Internet"
#     }
#   ]
#
#   tags = {
#     Environment = "Example"
#   }
# }

# Step 3: Create associations with proper null handling
# resource "azurerm_subnet_route_table_association" "associations" {
#   for_each = {
#     for subnet_key, subnet_config in var.subnet_configs :
#     subnet_key => {
#       subnet_id      = try(azurerm_subnet.example[subnet_key].id, null)
#       route_table_id = module.route_table.id
#     }
#     if subnet_config.associate_route_table == true && 
#        try(azurerm_subnet.example[subnet_key].id, null) != null
#   }
#
#   subnet_id      = each.value.subnet_id
#   route_table_id = each.value.route_table_id
# }

# ==============================================================================
# PATTERN 3: Using locals for cleaner code
# ==============================================================================

# locals {
#   # Create a clean map of associations to create
#   route_table_associations = {
#     for subnet_key, subnet_config in var.subnet_configs :
#     subnet_key => {
#       subnet_id      = azurerm_subnet.example[subnet_key].id
#       route_table_id = module.route_table.id
#     }
#     if subnet_config.associate_route_table == true
#   }
# }
#
# resource "azurerm_subnet_route_table_association" "associations" {
#   for_each = local.route_table_associations
#
#   subnet_id      = each.value.subnet_id
#   route_table_id = each.value.route_table_id
# }