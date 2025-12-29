# Terraform Azure DevOps Work Items Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps work items module for managing processes, work items, queries, and permissions.

## Limitations

- `query_folders.parent_key` supports single-level nesting and must reference a top-level folder (parent_key unset).

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "path/to/azuredevops_work_items"

  project_id = "00000000-0000-0000-0000-000000000000"

  processes = [
    {
      key                    = "custom"
      name                   = "custom_agile"
      parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
    }
  ]

  title = "Example Work Item"
  type  = "Issue"
  state = "Active"
}
```

## Multiple Work Items

Use module-level `for_each` to manage multiple work items:

```hcl
module "work_items" {
  for_each = {
    one = {
      title = "First Work Item"
      type  = "Task"
    }
    two = {
      title = "Second Work Item"
      type  = "Task"
    }
  }

  source     = "path/to/azuredevops_work_items"
  project_id = var.project_id

  title = each.value.title
  type  = each.value.type
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a simple work item.
- [Complete](examples/complete) - This example demonstrates processes, query folders, queries, and permissions with key-based references.
- [Secure](examples/secure) - This example demonstrates restricted permissions for work item areas, iterations, and tagging alongside a basic work item.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_area_permissions.area_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/area_permissions) | resource |
| [azuredevops_iteration_permissions.iteration_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/iteration_permissions) | resource |
| [azuredevops_tagging_permissions.tagging_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/tagging_permissions) | resource |
| [azuredevops_workitem.work_item](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitem) | resource |
| [azuredevops_workitemquery.query](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitemquery) | resource |
| [azuredevops_workitemquery_folder.query_folder](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitemquery_folder) | resource |
| [azuredevops_workitemquery_folder.query_folder_child](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitemquery_folder) | resource |
| [azuredevops_workitemquery_permissions.query_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitemquery_permissions) | resource |
| [azuredevops_workitemtrackingprocess_process.process](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitemtrackingprocess_process) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_area_path"></a> [area\_path](#input\_area\_path) | Area path for the work item. | `string` | `null` | no |
| <a name="input_area_permissions"></a> [area\_permissions](#input\_area\_permissions) | List of area permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    project_id  = optional(string)<br/>    path        = string<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_fields"></a> [custom\_fields](#input\_custom\_fields) | Custom fields to set on the work item. | `map(string)` | `null` | no |
| <a name="input_iteration_path"></a> [iteration\_path](#input\_iteration\_path) | Iteration path for the work item. | `string` | `null` | no |
| <a name="input_iteration_permissions"></a> [iteration\_permissions](#input\_iteration\_permissions) | List of iteration permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    project_id  = optional(string)<br/>    path        = string<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | Parent work item ID. | `number` | `null` | no |
| <a name="input_processes"></a> [processes](#input\_processes) | List of work item processes to manage. | <pre>list(object({<br/>    key                    = optional(string)<br/>    name                   = string<br/>    parent_process_type_id = string<br/>    description            = optional(string)<br/>    is_default             = optional(bool)<br/>    is_enabled             = optional(bool)<br/>    reference_name         = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default Azure DevOps project ID for project-scoped resources. | `string` | `null` | no |
| <a name="input_queries"></a> [queries](#input\_queries) | List of work item queries to manage. | <pre>list(object({<br/>    key        = optional(string)<br/>    project_id = optional(string)<br/>    name       = string<br/>    wiql       = string<br/>    area       = optional(string)<br/>    parent_id  = optional(number)<br/>    parent_key = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_query_folders"></a> [query\_folders](#input\_query\_folders) | List of work item query folders to manage. | <pre>list(object({<br/>    key        = optional(string)<br/>    project_id = optional(string)<br/>    name       = string<br/>    area       = optional(string)<br/>    parent_id  = optional(number)<br/>    parent_key = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_query_permissions"></a> [query\_permissions](#input\_query\_permissions) | List of query permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    project_id  = optional(string)<br/>    path        = optional(string)<br/>    query_key   = optional(string)<br/>    folder_key  = optional(string)<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_state"></a> [state](#input\_state) | State of the work item. | `string` | `null` | no |
| <a name="input_tagging_permissions"></a> [tagging\_permissions](#input\_tagging\_permissions) | List of tagging permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    project_id  = optional(string)<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to associate with the work item. | `list(string)` | `null` | no |
| <a name="input_title"></a> [title](#input\_title) | Title of the work item. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Work item type (for example, Issue or Task). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_area_permission_ids"></a> [area\_permission\_ids](#output\_area\_permission\_ids) | Map of area permission IDs keyed by permission key. |
| <a name="output_iteration_permission_ids"></a> [iteration\_permission\_ids](#output\_iteration\_permission\_ids) | Map of iteration permission IDs keyed by permission key. |
| <a name="output_process_ids"></a> [process\_ids](#output\_process\_ids) | Map of process IDs keyed by process key. |
| <a name="output_query_folder_ids"></a> [query\_folder\_ids](#output\_query\_folder\_ids) | Map of query folder IDs keyed by folder key. |
| <a name="output_query_ids"></a> [query\_ids](#output\_query\_ids) | Map of query IDs keyed by query key. |
| <a name="output_query_permission_ids"></a> [query\_permission\_ids](#output\_query\_permission\_ids) | Map of query permission IDs keyed by permission key. |
| <a name="output_tagging_permission_ids"></a> [tagging\_permission\_ids](#output\_tagging\_permission\_ids) | Map of tagging permission IDs keyed by permission key. |
| <a name="output_work_item_id"></a> [work\_item\_id](#output\_work\_item\_id) | The ID of the created work item. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/IMPORT.md](docs/IMPORT.md) - Import existing work items, queries, and permissions into the module
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
