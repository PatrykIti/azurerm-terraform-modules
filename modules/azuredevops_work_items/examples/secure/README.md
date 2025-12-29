# Secure Work Items Example

This example demonstrates restricted permissions for work item areas, iterations, and tagging alongside a basic work item.

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
| <a name="input_principal_descriptor"></a> [principal\_descriptor](#input\_principal\_descriptor) | Principal descriptor for permissions. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_area_permission_ids"></a> [area\_permission\_ids](#output\_area\_permission\_ids) | Area permission IDs created in this example. |
| <a name="output_iteration_permission_ids"></a> [iteration\_permission\_ids](#output\_iteration\_permission\_ids) | Iteration permission IDs created in this example. |
| <a name="output_tagging_permission_ids"></a> [tagging\_permission\_ids](#output\_tagging\_permission\_ids) | Tagging permission IDs created in this example. |
| <a name="output_work_item_id"></a> [work\_item\_id](#output\_work\_item\_id) | Work item ID created in this example. |
<!-- END_TF_DOCS -->