output "role_binding_name" {
  description = "Created RoleBinding name."
  value       = module.kubernetes_role_binding.name
}

output "role_binding_subject_count" {
  description = "Number of bound subjects."
  value       = length(module.kubernetes_role_binding.subjects)
}
