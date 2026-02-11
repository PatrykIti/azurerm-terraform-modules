output "primary_namespace_id" {
  description = "The ID of the primary Event Hub Namespace."
  value       = module.primary_namespace.id
}

output "secondary_namespace_id" {
  description = "The ID of the secondary Event Hub Namespace."
  value       = module.secondary_namespace.id
}

output "resource_group_name" {
  description = "The resource group name for the namespaces."
  value       = azurerm_resource_group.example.name
}
