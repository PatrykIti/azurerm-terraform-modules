# Azure DevOps Project Permissions

locals {
  permissions_by_key = {
    for permission in var.permissions : coalesce(permission.key, permission.group_name, permission.principal) => permission
  }

  permissions_with_group_name = {
    for key, permission in local.permissions_by_key : key => permission
    if permission.group_name != null
  }
}

data "azuredevops_group" "permission_group" {
  for_each = local.permissions_with_group_name

  name       = each.value.group_name
  project_id = each.value.scope == "project" ? var.project_id : null
}

resource "azuredevops_project_permissions" "permission" {
  for_each = local.permissions_by_key

  project_id  = var.project_id
  principal   = each.value.principal != null ? each.value.principal : data.azuredevops_group.permission_group[each.key].id
  permissions = each.value.permissions
  replace     = each.value.replace
}
