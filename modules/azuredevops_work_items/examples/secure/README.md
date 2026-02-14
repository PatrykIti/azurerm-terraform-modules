# Secure Work Items Example

This example demonstrates stricter field usage (area/iteration/custom fields) for a single work item.

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
| <a name="module_azuredevops_work_items"></a> [azuredevops\_work\_items](#module\_azuredevops\_work\_items) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_area_path"></a> [area\_path](#input\_area\_path) | Area path to assign to the work item. | `string` | `"\\"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description text for the work item. | `string` | `"Work item managed by Terraform secure example."` | no |
| <a name="input_iteration_path"></a> [iteration\_path](#input\_iteration\_path) | Iteration path to assign to the work item. | `string` | `"\\"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_title"></a> [title](#input\_title) | Title for the secure work item example. | `string` | `"Secure Example Work Item"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_work_item_id"></a> [work\_item\_id](#output\_work\_item\_id) | Work item ID created in this example. |
<!-- END_TF_DOCS -->