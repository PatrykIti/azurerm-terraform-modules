# Complete Work Items Example

This example demonstrates processes, query folders, queries, and permissions with key-based references.

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
| <a name="input_parent_process_type_id"></a> [parent\_process\_type\_id](#input\_parent\_process\_type\_id) | Parent process type ID for custom processes. | `string` | `"adcc42ab-9882-485e-a3ed-7678f01f66bc"` | no |
| <a name="input_principal_descriptor"></a> [principal\_descriptor](#input\_principal\_descriptor) | Principal descriptor for query permissions. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_process_ids"></a> [process\_ids](#output\_process\_ids) | Process IDs created in this example. |
| <a name="output_query_folder_ids"></a> [query\_folder\_ids](#output\_query\_folder\_ids) | Query folder IDs created in this example. |
| <a name="output_query_ids"></a> [query\_ids](#output\_query\_ids) | Query IDs created in this example. |
| <a name="output_query_permission_ids"></a> [query\_permission\_ids](#output\_query\_permission\_ids) | Query permission IDs created in this example. |
| <a name="output_work_item_id"></a> [work\_item\_id](#output\_work\_item\_id) | Work item ID created in this example. |
<!-- END_TF_DOCS -->