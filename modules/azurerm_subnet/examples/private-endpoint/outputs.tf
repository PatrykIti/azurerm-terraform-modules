# Outputs for Secure Subnet Example

output "subnet_id" {
  description = "The ID of the created secure subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created secure subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the created secure subnet"
  value       = module.subnet.address_prefixes
}

output "subnet_service_endpoints" {
  description = "The service endpoints enabled on the secure subnet"
  value       = module.subnet.service_endpoints
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group associated with the secure subnet"
  value       = azurerm_network_security_group.secure.id
}

output "route_table_id" {
  description = "The ID of the Route Table associated with the secure subnet"
  value       = azurerm_route_table.secure.id
}

output "ddos_protection_plan_id" {
  description = "The ID of the DDoS Protection Plan"
  value       = azurerm_network_ddos_protection_plan.example.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for security monitoring"
  value       = azurerm_log_analytics_workspace.security.id
}

output "storage_account_id" {
  description = "The ID of the Storage Account for security logs"
  value       = azurerm_storage_account.security.id
}

output "network_watcher_id" {
  description = "The ID of the Network Watcher"
  value       = azurerm_network_watcher.example.id
}

output "flow_log_id" {
  description = "The ID of the Network Watcher Flow Log"
  value       = azurerm_network_watcher_flow_log.secure.id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}