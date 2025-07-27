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

output "private_endpoint_network_policies_enabled" {
  description = "Whether network policies are enabled for private endpoints"
  value       = module.subnet.private_endpoint_network_policies_enabled
}
