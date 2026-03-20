output "namespace_name" {
  description = "Created namespace name."
  value       = module.kubernetes_namespace.name
}

output "namespace_uid" {
  description = "Created namespace UID."
  value       = module.kubernetes_namespace.uid
}

output "resource_group_name" {
  description = "Resource group name for the fixture."
  value       = azurerm_resource_group.test.name
}
