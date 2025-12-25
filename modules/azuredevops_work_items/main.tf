locals {
  work_items           = { for idx, item in var.work_items : idx => item }
  query_folders        = { for idx, folder in var.query_folders : idx => folder }
  queries              = { for idx, query in var.queries : idx => query }
  query_permissions    = { for idx, perm in var.query_permissions : idx => perm }
  area_permissions     = { for idx, perm in var.area_permissions : idx => perm }
  iteration_permissions = { for idx, perm in var.iteration_permissions : idx => perm }
  tagging_permissions  = { for idx, perm in var.tagging_permissions : idx => perm }
}

resource "azuredevops_workitemtrackingprocess_process" "process" {
  for_each = var.processes

  name                   = coalesce(each.value.name, each.key)
  parent_process_type_id = each.value.parent_process_type_id
  description            = try(each.value.description, null)
  is_default             = try(each.value.is_default, null)
  is_enabled             = try(each.value.is_enabled, null)
  reference_name         = try(each.value.reference_name, null)
}

resource "azuredevops_workitem" "work_item" {
  for_each = local.work_items

  project_id     = coalesce(each.value.project_id, var.project_id)
  title          = each.value.title
  type           = each.value.type
  state          = try(each.value.state, null)
  tags           = try(each.value.tags, null)
  area_path      = try(each.value.area_path, null)
  iteration_path = try(each.value.iteration_path, null)
  parent_id      = try(each.value.parent_id, null)
  custom_fields  = try(each.value.custom_fields, null)
}

resource "azuredevops_workitemquery_folder" "query_folder" {
  for_each = local.query_folders

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  area       = try(each.value.area, null)
  parent_id  = try(each.value.parent_id, null)
}

resource "azuredevops_workitemquery" "query" {
  for_each = local.queries

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  wiql       = each.value.wiql
  area       = try(each.value.area, null)
  parent_id  = try(each.value.parent_id, null)
}

resource "azuredevops_workitemquery_permissions" "query_permissions" {
  for_each = local.query_permissions

  project_id  = coalesce(each.value.project_id, var.project_id)
  path        = try(each.value.path, null)
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = try(each.value.replace, true)
}

resource "azuredevops_area_permissions" "area_permissions" {
  for_each = local.area_permissions

  project_id  = coalesce(each.value.project_id, var.project_id)
  path        = try(each.value.path, null)
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = try(each.value.replace, true)
}

resource "azuredevops_iteration_permissions" "iteration_permissions" {
  for_each = local.iteration_permissions

  project_id  = coalesce(each.value.project_id, var.project_id)
  path        = try(each.value.path, null)
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = try(each.value.replace, true)
}

resource "azuredevops_tagging_permissions" "tagging_permissions" {
  for_each = local.tagging_permissions

  project_id  = coalesce(each.value.project_id, var.project_id)
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = try(each.value.replace, true)
}
