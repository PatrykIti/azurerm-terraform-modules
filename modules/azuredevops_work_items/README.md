# Terraform Azure DevOps Work Items Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps work items module for managing a single work item resource (atomic scope).

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "path/to/azuredevops_work_items"

  project_id = "00000000-0000-0000-0000-000000000000"

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
- [Complete](examples/complete) - This example demonstrates parent/child work item composition using two module instances.
- [Secure](examples/secure) - This example demonstrates stricter field usage (area/iteration/custom fields) for a single work item.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing work items into the module


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
| [azuredevops_workitem.work_item](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/workitem) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_area_path"></a> [area\_path](#input\_area\_path) | Area path for the work item. | `string` | `null` | no |
| <a name="input_custom_fields"></a> [custom\_fields](#input\_custom\_fields) | Custom fields to set on the work item. | `map(string)` | `null` | no |
| <a name="input_iteration_path"></a> [iteration\_path](#input\_iteration\_path) | Iteration path for the work item. | `string` | `null` | no |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | Parent work item ID. | `number` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID for the work item. | `string` | n/a | yes |
| <a name="input_state"></a> [state](#input\_state) | State of the work item. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to associate with the work item. | `list(string)` | `null` | no |
| <a name="input_title"></a> [title](#input\_title) | Title of the work item. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Work item type (for example, Issue or Task). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_work_item_id"></a> [work\_item\_id](#output\_work\_item\_id) | The ID of the created work item. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
