output "kubernetes_role_id" {
  description = "The ID of the created Kubernetes Role"
  value       = module.kubernetes_role.id
}

output "kubernetes_role_name" {
  description = "The name of the created Kubernetes Role"
  value       = module.kubernetes_role.name
}
