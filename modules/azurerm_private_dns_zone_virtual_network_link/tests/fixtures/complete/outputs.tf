output "private_dns_zone_virtual_network_link_id" {
  description = "The ID of the created Private DNS Zone Virtual Network Link"
  value       = module.private_dns_zone_virtual_network_link.id
}

output "private_dns_zone_virtual_network_link_name" {
  description = "The name of the created Private DNS Zone Virtual Network Link"
  value       = module.private_dns_zone_virtual_network_link.name
}
