output "role_binding_name" {
  value = module.kubernetes_role_binding.name
}

output "subject_count" {
  value = length(module.kubernetes_role_binding.subjects)
}
