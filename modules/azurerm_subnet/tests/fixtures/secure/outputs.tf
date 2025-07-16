output "subnet_id" {
  description = "The ID of the created Subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created Subnet"
  value       = module.subnet.name
}
