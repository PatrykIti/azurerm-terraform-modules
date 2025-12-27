locals {
  work_items_by_key = {
    for item in var.work_items : coalesce(item.key, item.title) => item
  }
  work_items_root = {
    for key, item in local.work_items_by_key : key => item if item.parent_key == null
  }
  work_items_child = {
    for key, item in local.work_items_by_key : key => item if item.parent_key != null
  }
  query_folders_by_key = {
    for folder in var.query_folders : coalesce(folder.key, folder.name) => folder
  }
  query_folders_root = {
    for key, folder in local.query_folders_by_key : key => folder if folder.parent_key == null
  }
  query_folders_child = {
    for key, folder in local.query_folders_by_key : key => folder if folder.parent_key != null
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
  for_each = local.work_items_root

  project_id     = coalesce(each.value.project_id, var.project_id)
  title          = each.value.title
  type           = each.value.type
  state          = try(each.value.state, null)
  tags           = try(each.value.tags, null)
  area_path      = try(each.value.area_path, null)
  iteration_path = try(each.value.iteration_path, null)
  parent_id = try(each.value.parent_id, null)
  custom_fields = try(each.value.custom_fields, null)
}

resource "azuredevops_workitem" "work_item_child" {
  for_each = local.work_items_child

  project_id     = coalesce(each.value.project_id, var.project_id)
  title          = each.value.title
  type           = each.value.type
  state          = try(each.value.state, null)
  tags           = try(each.value.tags, null)
  area_path      = try(each.value.area_path, null)
  iteration_path = try(each.value.iteration_path, null)
  parent_id      = tonumber(azuredevops_workitem.work_item[each.value.parent_key].id)
  custom_fields  = try(each.value.custom_fields, null)
}

resource "azuredevops_workitemquery_folder" "query_folder" {
  for_each = local.query_folders_root

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  area       = try(each.value.area, null)
  parent_id  = try(each.value.parent_id, null)
}

resource "azuredevops_workitemquery_folder" "query_folder_child" {
  for_each = local.query_folders_child

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  area       = try(each.value.area, null)
  parent_id  = tonumber(azuredevops_workitemquery_folder.query_folder[each.value.parent_key].id)
}

locals {
  query_folder_ids = merge(
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder : key => folder.id }, {}),
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder_child : key => folder.id }, {})
  )
  query_folder_paths_root = {
    for key, folder in local.query_folders_by_key :
    key => "${folder.area}/${folder.name}"
    if folder.area != null
  }
  query_folder_paths_from_inputs = merge(
    local.query_folder_paths_root,
    {
      for key, folder in local.query_folders_by_key :
      key => "${local.query_folder_paths_root[folder.parent_key]}/${folder.name}"
      if folder.parent_key != null && contains(keys(local.query_folder_paths_root), folder.parent_key)
    }
  )
  query_folder_paths_from_resources = merge(
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder : key => folder.path }, {}),
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder_child : key => folder.path }, {})
  )
  query_folder_paths_by_id = merge(
    try({ for _, folder in azuredevops_workitemquery_folder.query_folder : tostring(folder.id) => folder.path }, {}),
    try({ for _, folder in azuredevops_workitemquery_folder.query_folder_child : tostring(folder.id) => folder.path }, {})
  )
  query_paths = {
    for key, query in local.queries_by_key : key => (
      query.parent_key != null ? (
        lookup(local.query_folder_paths_from_inputs, query.parent_key, null) != null ?
        "${local.query_folder_paths_from_inputs[query.parent_key]}/${query.name}" :
        null
      ) :
      query.area != null ? "${query.area}/${query.name}" :
      (query.parent_id != null ? try("${local.query_folder_paths_by_id[tostring(query.parent_id)]}/${query.name}", null) : null)
    )
  }
}

resource "azuredevops_workitemquery" "query" {
  for_each = local.queries_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  wiql       = each.value.wiql
  area       = try(each.value.area, null)
  parent_id = each.value.parent_key != null ? tonumber(local.query_folder_ids[each.value.parent_key]) : (
    try(each.value.parent_id, null)
  )
}

resource "azuredevops_workitemquery_permissions" "query_permissions" {
  for_each = local.query_permissions_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  path = each.value.query_key != null ? local.query_paths[each.value.query_key] : (
    each.value.folder_key != null ? (
      lookup(local.query_folder_paths_from_inputs, each.value.folder_key, null) != null ?
      local.query_folder_paths_from_inputs[each.value.folder_key] :
      lookup(local.query_folder_paths_from_resources, each.value.folder_key, null)
    ) : each.value.path
  )
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace

  depends_on = [azuredevops_workitemquery.query]
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
