output "id" {
  description = "The ID of the Kubernetes Role Binding"
  value       = try(azurerm_kubernetes_role_binding.main.id, null)
}

output "name" {
  description = "The name of the Kubernetes Role Binding"
  value       = try(azurerm_kubernetes_role_binding.main.name, null)
}

output "location" {
  description = "The primary location of the kubernetes_role_binding"
  value       = try(azurerm_kubernetes_role_binding.main.location, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the Kubernetes Role Binding"
  value       = try(azurerm_kubernetes_role_binding.main.resource_group_name, null)
}

# TODO: Add specific outputs based on the resource type
# Example outputs for common Azure resources:

# output "primary_endpoint" {
#   description = "The endpoint URL for the primary location"
#   value       = try(azurerm_kubernetes_role_binding.main.primary_endpoint, null)
# }

# output "secondary_endpoint" {
#   description = "The endpoint URL for the secondary location"
#   value       = try(azurerm_kubernetes_role_binding.main.secondary_endpoint, null)
# }

# output "primary_access_key" {
#   description = "The primary access key for the kubernetes_role_binding"
#   value       = try(azurerm_kubernetes_role_binding.main.primary_access_key, null)
#   sensitive   = true
# }

# output "secondary_access_key" {
#   description = "The secondary access key for the kubernetes_role_binding"
#   value       = try(azurerm_kubernetes_role_binding.main.secondary_access_key, null)
#   sensitive   = true
# }

# output "connection_string" {
#   description = "The connection string for the kubernetes_role_binding"
#   value       = try(azurerm_kubernetes_role_binding.main.primary_connection_string, null)
#   sensitive   = true
# }

# Private Endpoint Outputs
output "private_endpoints" {
  description = "Information about the created private endpoints"
  value = {
    for idx, pe in azurerm_private_endpoint.main : pe.name => {
      id                 = pe.id
      name               = pe.name
      private_ip_address = pe.private_service_connection[0].private_ip_address
      fqdn               = try(pe.custom_dns_configs[0].fqdn, null)
    }
  }
}

# Network Rules Output
output "network_rules" {
  description = "The network rules configuration applied to the kubernetes_role_binding"
  value = var.network_rules != null ? {
    default_action             = var.network_rules.default_action
    bypass                     = var.network_rules.bypass
    ip_rules                   = var.network_rules.ip_rules
    virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
  } : null
}