# Main subnet outputs
output "subnet_id" {
  description = "The ID of the created Subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created Subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the created Subnet"
  value       = module.subnet.address_prefixes
}

output "subnet_service_endpoints" {
  description = "The service endpoints enabled on the subnet"
  value       = module.subnet.service_endpoints
}

output "subnet_delegations" {
  description = "The delegations configured on the subnet"
  value       = module.subnet.delegations
}

# Associated resources
output "network_security_group_association_id" {
  description = "The ID of the NSG association"
  value       = module.subnet.network_security_group_association_id
}

output "route_table_association_id" {
  description = "The ID of the Route Table association"
  value       = module.subnet.route_table_association_id
}

# Secondary subnet outputs (without delegation)
output "subnet_no_delegation_id" {
  description = "The ID of the subnet without delegation"
  value       = module.subnet_no_delegation.id
}

output "subnet_no_delegation_name" {
  description = "The name of the subnet without delegation"
  value       = module.subnet_no_delegation.name
}

# Supporting resources
output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.example.id
}

output "route_table_id" {
  description = "The ID of the Route Table"
  value       = azurerm_route_table.example.id
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}