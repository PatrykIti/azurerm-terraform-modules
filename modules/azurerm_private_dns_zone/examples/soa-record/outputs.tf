output "private_dns_zone_id" {
  description = "The ID of the created Private DNS Zone"
  value       = module.private_dns_zone.id
}

output "private_dns_zone_name" {
  description = "The name of the created Private DNS Zone"
  value       = module.private_dns_zone.name
}
