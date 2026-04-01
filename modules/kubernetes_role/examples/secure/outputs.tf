output "role_name" {
  description = "Created role name."
  value       = module.kubernetes_role.name
}

output "role_rules" {
  description = "Rendered role rules."
  value       = module.kubernetes_role.rules
}
