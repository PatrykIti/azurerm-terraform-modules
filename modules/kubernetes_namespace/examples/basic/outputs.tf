output "namespace_name" {
  description = "Created namespace name."
  value       = module.kubernetes_namespace.name
}

output "namespace_uid" {
  description = "Created namespace UID."
  value       = module.kubernetes_namespace.uid
}
