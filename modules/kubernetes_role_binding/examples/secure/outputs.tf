output "kubernetes_role_binding_id" {
  description = "The ID of the created Kubernetes Role Binding"
  value       = module.kubernetes_role_binding.id
}

output "kubernetes_role_binding_name" {
  description = "The name of the created Kubernetes Role Binding"
  value       = module.kubernetes_role_binding.name
}
