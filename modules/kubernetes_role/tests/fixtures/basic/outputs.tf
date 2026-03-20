output "role_name" {
  description = "Created role name."
  value       = module.kubernetes_role.name
}

output "role_namespace" {
  description = "Created role namespace."
  value       = module.kubernetes_role.namespace
}
