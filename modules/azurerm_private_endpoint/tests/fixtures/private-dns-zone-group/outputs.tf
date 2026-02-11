output "private_endpoint_id" {
  description = "The ID of the created Private Endpoint."
  value       = module.private_endpoint.id
}

output "private_endpoint_name" {
  description = "The name of the created Private Endpoint."
  value       = module.private_endpoint.name
}

output "private_dns_zone_group" {
  description = "The DNS zone group output from the module."
  value       = module.private_endpoint.private_dns_zone_group
}
