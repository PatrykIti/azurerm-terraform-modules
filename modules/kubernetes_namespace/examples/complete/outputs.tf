output "namespace_name" {
  description = "Created namespace name."
  value       = module.kubernetes_namespace.name
}

output "namespace_labels" {
  description = "Labels assigned to the namespace."
  value       = module.kubernetes_namespace.labels
}

output "namespace_annotations" {
  description = "Annotations assigned to the namespace."
  value       = module.kubernetes_namespace.annotations
}
