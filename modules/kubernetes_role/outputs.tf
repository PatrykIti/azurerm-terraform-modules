output "id" {
  description = "The Terraform ID of the Role."
  value       = try(kubernetes_role_v1.role.id, null)
}

output "name" {
  description = "The Role name."
  value       = try(kubernetes_role_v1.role.metadata[0].name, null)
}

output "namespace" {
  description = "The namespace of the Role."
  value       = try(kubernetes_role_v1.role.metadata[0].namespace, null)
}

output "rules" {
  description = "The rendered Role rules."
  value = [
    for rule in kubernetes_role_v1.role.rule : {
      api_groups     = rule.api_groups
      resources      = rule.resources
      verbs          = rule.verbs
      resource_names = try(rule.resource_names, null)
    }
  ]
}
