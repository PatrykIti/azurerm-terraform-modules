output "kubernetes_secrets_id" {
  description = "The ID of the created Kubernetes Secrets"
  value       = module.kubernetes_secrets.id
}

output "kubernetes_secrets_name" {
  description = "The name of the created Kubernetes Secrets"
  value       = module.kubernetes_secrets.name
}
