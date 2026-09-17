output "role_binding_name" {
  description = "Created RoleBinding name."
  value       = module.kubernetes_role_binding.name
}

output "role_binding_subjects" {
  description = "Subjects bound by the RoleBinding."
  value       = module.kubernetes_role_binding.subjects
}
