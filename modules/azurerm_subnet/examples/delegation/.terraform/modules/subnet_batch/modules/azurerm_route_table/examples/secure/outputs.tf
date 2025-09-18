output "route_table_id" {
  description = "The ID of the created Route Table"
  value       = module.route_table.id
}

output "route_table_name" {
  description = "The name of the created Route Table"
  value       = module.route_table.name
}
