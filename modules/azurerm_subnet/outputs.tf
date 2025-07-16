# Core Subnet Outputs
output "id" {
  description = "The ID of the Subnet"
  value       = azurerm_subnet.subnet.id
}

output "name" {
  description = "The name of the Subnet"
  value       = azurerm_subnet.subnet.name
}

output "resource_group_name" {
  description = "The name of the Resource Group where the subnet exists"
  value       = azurerm_subnet.subnet.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the Virtual Network where the subnet exists"
  value       = azurerm_subnet.subnet.virtual_network_name
}

output "address_prefixes" {
  description = "The address prefixes for the subnet"
  value       = azurerm_subnet.subnet.address_prefixes
}

# Service Endpoints
output "service_endpoints" {
  description = "The list of Service endpoints enabled on this subnet"
  value       = azurerm_subnet.subnet.service_endpoints
}

output "service_endpoint_policy_ids" {
  description = "The list of Service Endpoint Policy IDs associated with the subnet"
  value       = azurerm_subnet.subnet.service_endpoint_policy_ids
}

# Network Policies
output "private_endpoint_network_policies_enabled" {
  description = "Whether network policies are enabled for private endpoints on this subnet"
  value       = azurerm_subnet.subnet.private_endpoint_network_policies_enabled
}

output "private_link_service_network_policies_enabled" {
  description = "Whether network policies are enabled for private link service on this subnet"
  value       = azurerm_subnet.subnet.private_link_service_network_policies_enabled
}

# Delegations
output "delegations" {
  description = "The delegations configured on the subnet"
  value = {
    for k, v in var.delegations : k => {
      name    = v.service_delegation.name
      actions = v.service_delegation.actions
    }
  }
}

# Associated Resources
output "network_security_group_id" {
  description = "The ID of the Network Security Group associated with the subnet"
  value       = var.network_security_group_id
}

output "route_table_id" {
  description = "The ID of the Route Table associated with the subnet"
  value       = var.route_table_id
}

# Association Resource IDs
output "network_security_group_association_id" {
  description = "The ID of the Subnet to Network Security Group Association"
  value       = length(azurerm_subnet_network_security_group_association.subnet) > 0 ? azurerm_subnet_network_security_group_association.subnet[0].id : null
}

output "route_table_association_id" {
  description = "The ID of the Subnet to Route Table Association"
  value       = length(azurerm_subnet_route_table_association.subnet) > 0 ? azurerm_subnet_route_table_association.subnet[0].id : null
}