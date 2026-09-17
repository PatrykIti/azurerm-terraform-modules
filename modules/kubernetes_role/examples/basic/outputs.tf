output "role_name" {
  description = "Created role name."
  value       = module.kubernetes_role.name
}

output "role_namespace" {
  description = "Namespace of the created role."
  value       = module.kubernetes_role.namespace
}
