locals {
  work_items_by_key = {
    for item in var.work_items : coalesce(item.key, item.title) => item
  }
  query_folders_by_key = {
    for folder in var.query_folders : coalesce(folder.key, folder.name) => folder
  }
  queries_by_key = {
    for query in var.queries : coalesce(query.key, query.name) => query
  }
  query_permissions_by_key = {
    for perm in var.query_permissions :
    coalesce(perm.key, perm.principal, perm.path, perm.query_key, perm.folder_key) => perm
  }
  area_permissions_by_key = {
    for perm in var.area_permissions : coalesce(perm.key, perm.principal, perm.path) => perm
  }
  iteration_permissions_by_key = {
    for perm in var.iteration_permissions : coalesce(perm.key, perm.principal, perm.path) => perm
  }
  tagging_permissions_by_key = {
    for perm in var.tagging_permissions : coalesce(perm.key, perm.principal) => perm
  }
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
  for_each = local.work_items_by_key

  project_id     = coalesce(each.value.project_id, var.project_id)
  title          = each.value.title
  type           = each.value.type
  state          = try(each.value.state, null)
  tags           = try(each.value.tags, null)
  area_path      = try(each.value.area_path, null)
  iteration_path = try(each.value.iteration_path, null)
  parent_id = each.value.parent_key != null ? tonumber(azuredevops_workitem.work_item[each.value.parent_key].id) : (
    try(each.value.parent_id, null)
  )
  custom_fields = try(each.value.custom_fields, null)
}

resource "azuredevops_workitemquery_folder" "query_folder" {
  for_each = local.query_folders_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  area       = try(each.value.area, null)
  parent_id = each.value.parent_key != null ? tonumber(azuredevops_workitemquery_folder.query_folder[each.value.parent_key].id) : (
    try(each.value.parent_id, null)
  )
}

resource "azuredevops_workitemquery" "query" {
  for_each = local.queries_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  wiql       = each.value.wiql
  area       = try(each.value.area, null)
  parent_id = each.value.parent_key != null ? tonumber(azuredevops_workitemquery_folder.query_folder[each.value.parent_key].id) : (
    try(each.value.parent_id, null)
  )
}

resource "azuredevops_workitemquery_permissions" "query_permissions" {
  for_each = local.query_permissions_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  path = each.value.query_key != null ? azuredevops_workitemquery.query[each.value.query_key].path : (
    each.value.folder_key != null ? azuredevops_workitemquery_folder.query_folder[each.value.folder_key].path : each.value.path
  )
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace
}

resource "azuredevops_area_permissions" "area_permissions" {
  for_each = local.area_permissions_by_key

  project_id  = coalesce(each.value.project_id, var.project_id)
  path        = each.value.path
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace
}

resource "azuredevops_iteration_permissions" "iteration_permissions" {
  for_each = local.iteration_permissions_by_key

  project_id  = coalesce(each.value.project_id, var.project_id)
  path        = each.value.path
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace
}

resource "azuredevops_tagging_permissions" "tagging_permissions" {
  for_each = local.tagging_permissions_by_key

  project_id  = coalesce(each.value.project_id, var.project_id)
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace
}
