output "namespace_name" {
  description = "Created namespace name."
  value       = module.kubernetes_namespace.name
}

output "namespace_labels" {
  description = "Created namespace labels."
  value       = module.kubernetes_namespace.labels
}

output "resource_group_name" {
  description = "Resource group name for the fixture."
  value       = azurerm_resource_group.test.name
}
