output "namespace_name" {
  description = "Created namespace name."
  value       = module.kubernetes_namespace.name
}

output "namespace_annotations" {
  description = "Created namespace annotations."
  value       = module.kubernetes_namespace.annotations
}
