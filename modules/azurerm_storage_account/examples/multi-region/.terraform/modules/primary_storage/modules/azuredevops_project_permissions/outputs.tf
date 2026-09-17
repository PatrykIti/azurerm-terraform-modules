output "permission_ids" {
  description = "Map of permission assignment IDs keyed by permission key."
  value       = { for key, permission in azuredevops_project_permissions.permission : key => permission.id }
}

output "permission_principals" {
  description = "Map of resolved principals keyed by permission key."
  value = {
    for key, permission in local.permissions_by_key :
    key => coalesce(permission.principal, try(data.azuredevops_group.permission_group[key].id, null))
  }
}
