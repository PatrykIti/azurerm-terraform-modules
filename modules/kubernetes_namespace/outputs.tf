output "id" {
  description = "The Terraform ID of the namespace."
  value       = try(kubernetes_namespace_v1.namespace.id, null)
}

output "name" {
  description = "The namespace name."
  value       = try(kubernetes_namespace_v1.namespace.metadata[0].name, null)
}

output "labels" {
  description = "Labels assigned to the namespace."
  value       = try(kubernetes_namespace_v1.namespace.metadata[0].labels, null)
}

output "annotations" {
  description = "Annotations assigned to the namespace."
  value       = try(kubernetes_namespace_v1.namespace.metadata[0].annotations, null)
}

output "generation" {
  description = "The generation of the namespace resource."
  value       = try(kubernetes_namespace_v1.namespace.metadata[0].generation, null)
}

output "resource_version" {
  description = "The resource version of the namespace."
  value       = try(kubernetes_namespace_v1.namespace.metadata[0].resource_version, null)
}

output "uid" {
  description = "The UID of the namespace."
  value       = try(kubernetes_namespace_v1.namespace.metadata[0].uid, null)
}
