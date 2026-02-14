# Complete Work Items Example

This example demonstrates parent/child work item composition using two module instances.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_work_item_child"></a> [work\_item\_child](#module\_work\_item\_child) | ../../ | n/a |
| <a name="module_work_item_parent"></a> [work\_item\_parent](#module\_work\_item\_parent) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_child_title"></a> [child\_title](#input\_child\_title) | Title for the child work item. | `string` | `"Example Child Work Item"` | no |
| <a name="input_parent_title"></a> [parent\_title](#input\_parent\_title) | Title for the parent work item. | `string` | `"Example Parent Work Item"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_work_item_ids"></a> [work\_item\_ids](#output\_work\_item\_ids) | Work item IDs created in this example. |
<!-- END_TF_DOCS -->