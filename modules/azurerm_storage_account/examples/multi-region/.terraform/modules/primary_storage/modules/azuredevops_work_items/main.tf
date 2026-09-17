# Azure DevOps Work Items

locals {
  processes_by_key = {
    for process in var.processes : coalesce(process.key, process.name) => process
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

  shared_queries_root   = "Shared Queries"
  shared_queries_prefix = "Shared Queries/"

  query_folder_ids = merge(
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder : key => folder.id }, {}),
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder_child : key => folder.id }, {})
  )
  query_folder_paths_from_resources = merge(
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder : key => folder.path }, {}),
    try({ for key, folder in azuredevops_workitemquery_folder.query_folder_child : key => folder.path }, {})
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
  query_folder_paths = merge(local.query_folder_paths_from_inputs, local.query_folder_paths_from_resources)
  query_folder_paths_by_id = {
    for key, folder_id in local.query_folder_ids :
    tostring(folder_id) => lookup(local.query_folder_paths_from_resources, key, null)
  }

  query_paths_from_inputs = {
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
  query_paths_from_resources = try({
    for key, query in azuredevops_workitemquery.query : key => query.path
  }, {})
  query_paths = merge(local.query_paths_from_inputs, local.query_paths_from_resources)

  query_folder_paths_relative = {
    for key, path in local.query_folder_paths :
    key => (
      path == null ? null :
      (path == local.shared_queries_root ? "/" :
      (startswith(path, local.shared_queries_prefix) ? "/${trimprefix(path, local.shared_queries_prefix)}" : path))
    )
  }
  query_paths_relative = {
    for key, path in local.query_paths :
    key => (
      path == null ? null :
      (path == local.shared_queries_root ? "/" :
      (startswith(path, local.shared_queries_prefix) ? "/${trimprefix(path, local.shared_queries_prefix)}" : path))
    )
  }
}

resource "azuredevops_workitemtrackingprocess_process" "process" {
  for_each = local.processes_by_key

  name                   = each.value.name
  parent_process_type_id = each.value.parent_process_type_id
  description            = try(each.value.description, null)
  is_default             = try(each.value.is_default, null)
  is_enabled             = try(each.value.is_enabled, null)
  reference_name         = try(each.value.reference_name, null)
}

resource "azuredevops_workitem" "work_item" {
  project_id     = var.project_id
  title          = var.title
  type           = var.type
  state          = var.state
  tags           = var.tags
  area_path      = var.area_path
  iteration_path = var.iteration_path
  parent_id      = var.parent_id
  custom_fields  = var.custom_fields

  lifecycle {
    precondition {
      condition     = var.project_id != null && length(trimspace(var.project_id)) > 0
      error_message = "project_id must be set to create a work item."
    }
  }
}

resource "azuredevops_workitemquery_folder" "query_folder" {
  for_each = local.query_folders_root

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  area       = try(each.value.area, null)
  parent_id  = each.value.parent_id == null ? null : tostring(each.value.parent_id)
}

resource "azuredevops_workitemquery_folder" "query_folder_child" {
  for_each = local.query_folders_child

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  area       = try(each.value.area, null)
  parent_id  = azuredevops_workitemquery_folder.query_folder[each.value.parent_key].id
}

resource "azuredevops_workitemquery" "query" {
  for_each = local.queries_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  name       = each.value.name
  wiql       = each.value.wiql
  area       = try(each.value.area, null)
  parent_id = each.value.parent_key != null ? local.query_folder_ids[each.value.parent_key] : (
    each.value.parent_id == null ? null : tostring(each.value.parent_id)
  )
}

resource "azuredevops_workitemquery_permissions" "query_permissions" {
  for_each = local.query_permissions_by_key

  project_id = coalesce(each.value.project_id, var.project_id)
  path = each.value.query_key != null ? lookup(local.query_paths_relative, each.value.query_key, null) : (
    each.value.folder_key != null ? lookup(local.query_folder_paths_relative, each.value.folder_key, null) : (
      each.value.path == local.shared_queries_root ? "/" :
      (startswith(each.value.path, local.shared_queries_prefix) ? "/${trimprefix(each.value.path, local.shared_queries_prefix)}" : each.value.path)
    )
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
