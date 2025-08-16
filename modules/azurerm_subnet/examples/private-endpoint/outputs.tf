# Outputs for Private Endpoint Subnet Example

output "private_endpoint_subnet_id" {
  description = "The ID of the subnet for private endpoints"
  value       = module.subnet_private_endpoints.id
}

output "private_endpoint_subnet_name" {
  description = "The name of the subnet for private endpoints"
  value       = module.subnet_private_endpoints.name
}

output "workload_subnet_id" {
  description = "The ID of the subnet for workloads"
  value       = module.subnet_workloads.id
}

output "workload_subnet_name" {
  description = "The name of the subnet for workloads"
  value       = module.subnet_workloads.name
}

output "private_endpoint_subnet_address_prefixes" {
  description = "The address prefixes of the private endpoint subnet"
  value       = module.subnet_private_endpoints.address_prefixes
}

output "workload_subnet_address_prefixes" {
  description = "The address prefixes of the workload subnet"
  value       = module.subnet_workloads.address_prefixes
}

output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.example.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.example.name
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.example.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.example.name
}

output "storage_private_endpoint_id" {
  description = "The ID of the Storage private endpoint"
  value       = azurerm_private_endpoint.storage_blob.id
}

output "keyvault_private_endpoint_id" {
  description = "The ID of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.keyvault.id
}

output "storage_private_endpoint_ip" {
  description = "The private IP address of the Storage private endpoint"
  value       = azurerm_private_endpoint.storage_blob.private_service_connection[0].private_ip_address
}

output "keyvault_private_endpoint_ip" {
  description = "The private IP address of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.keyvault.private_service_connection[0].private_ip_address
}

output "storage_private_dns_zone_id" {
  description = "The ID of the Storage private DNS zone"
  value       = azurerm_private_dns_zone.blob.id
}

output "keyvault_private_dns_zone_id" {
  description = "The ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.keyvault.id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}