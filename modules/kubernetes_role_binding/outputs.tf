output "id" {
  description = "The Terraform ID of the RoleBinding."
  value       = try(kubernetes_role_binding_v1.role_binding.id, null)
}

output "name" {
  description = "The RoleBinding name."
  value       = try(kubernetes_role_binding_v1.role_binding.metadata[0].name, null)
}

output "namespace" {
  description = "The namespace of the RoleBinding."
  value       = try(kubernetes_role_binding_v1.role_binding.metadata[0].namespace, null)
}

output "role_ref" {
  description = "The referenced role."
  value       = try(kubernetes_role_binding_v1.role_binding.role_ref[0], null)
}

output "subjects" {
  description = "The subjects bound by the RoleBinding."
  value       = try(kubernetes_role_binding_v1.role_binding.subject, [])
}
