output "role_name" {
  description = "Created role name."
  value       = module.kubernetes_role.name
}

output "role_rule_count" {
  description = "Number of rendered rules."
  value       = length(module.kubernetes_role.rules)
}
