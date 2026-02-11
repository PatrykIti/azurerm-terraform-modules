output "primary_server_id" {
  description = "Primary PostgreSQL Flexible Server ID."
  value       = module.primary.id
}

output "replica_server_id" {
  description = "Replica PostgreSQL Flexible Server ID."
  value       = module.replica.id
}

output "virtual_endpoints" {
  description = "Virtual endpoints created in the replica module."
  value       = module.replica.virtual_endpoints
}
