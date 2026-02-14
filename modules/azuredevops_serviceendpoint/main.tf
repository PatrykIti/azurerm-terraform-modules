# Azure DevOps Service Endpoint (Generic)

locals {
  permission_value_map = {
    allow  = "Allow"
    deny   = "Deny"
    notset = "NotSet"
  }

  serviceendpoint_permissions = {
    for permission in var.serviceendpoint_permissions :
    coalesce(permission.key, permission.principal) => {
      principal   = permission.principal
      permissions = { for name, status in permission.permissions : name => local.permission_value_map[lower(status)] }
      replace     = try(permission.replace, true)
    }
  }
}

resource "azuredevops_serviceendpoint_generic" "generic" {
  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_generic.service_endpoint_name
  server_url            = var.serviceendpoint_generic.server_url
  username              = try(var.serviceendpoint_generic.username, null)
  password              = try(var.serviceendpoint_generic.password, null)
  description           = try(var.serviceendpoint_generic.description, null)
}

resource "azuredevops_serviceendpoint_permissions" "permissions" {
  for_each = local.serviceendpoint_permissions

  project_id         = var.project_id
  serviceendpoint_id = azuredevops_serviceendpoint_generic.generic.id
  principal          = each.value.principal
  permissions        = each.value.permissions
  replace            = each.value.replace
}
