# Main secure subnet outputs
output "subnet_id" {
  description = "The ID of the secure subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the secure subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the secure subnet"
  value       = module.subnet.address_prefixes
}

output "subnet_service_endpoints" {
  description = "The service endpoints enabled on the secure subnet"
  value       = module.subnet.service_endpoints
}

# Private endpoint subnet outputs
output "private_endpoint_subnet_id" {
  description = "The ID of the private endpoint subnet"
  value       = module.subnet_private_endpoints.id
}

output "private_endpoint_subnet_name" {
  description = "The name of the private endpoint subnet"
  value       = module.subnet_private_endpoints.name
}

# Security resources
output "network_security_group_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.example.id
}

output "network_security_group_rules" {
  description = "The security rules configured in the NSG"
  value = {
    for rule in azurerm_network_security_group.example.security_rule : rule.name => {
      direction = rule.direction
      access    = rule.access
      priority  = rule.priority
      protocol  = rule.protocol
    }
  }
}

output "route_table_id" {
  description = "The ID of the Route Table"
  value       = azurerm_route_table.example.id
}

output "service_endpoint_policy_id" {
  description = "The ID of the Service Endpoint Policy"
  value       = azurerm_subnet_service_endpoint_storage_policy.example.id
}

# Supporting resources
output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}