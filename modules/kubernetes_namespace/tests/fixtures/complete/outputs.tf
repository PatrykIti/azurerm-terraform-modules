output "kubernetes_namespace_id" {
  description = "The ID of the created Kubernetes Namespace"
  value       = module.kubernetes_namespace.id
}

output "kubernetes_namespace_name" {
  description = "The name of the created Kubernetes Namespace"
  value       = module.kubernetes_namespace.name
}
