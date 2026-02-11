output "private_endpoint_id" {
  description = "The ID of the created Private Endpoint."
  value       = module.private_endpoint.id
}

output "private_endpoint_name" {
  description = "The name of the created Private Endpoint."
  value       = module.private_endpoint.name
}

output "private_ip_address" {
  description = "The private IP address from the service connection."
  value       = module.private_endpoint.private_ip_address
}
