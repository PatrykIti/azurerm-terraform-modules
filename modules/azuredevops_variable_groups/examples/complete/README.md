# Complete Variable Groups Example

This example demonstrates a variable group with Key Vault integration, variable group permissions, and library permissions.

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
| <a name="module_azuredevops_variable_groups"></a> [azuredevops\_variable\_groups](#module\_azuredevops\_variable\_groups) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_vault_service_endpoint_id"></a> [key\_vault\_service\_endpoint\_id](#input\_key\_vault\_service\_endpoint\_id) | Service endpoint ID for the Key Vault integration. | `string` | n/a | yes |
| <a name="input_library_principal_descriptor"></a> [library\_principal\_descriptor](#input\_library\_principal\_descriptor) | Principal descriptor for library permissions. | `string` | n/a | yes |
| <a name="input_principal_descriptor"></a> [principal\_descriptor](#input\_principal\_descriptor) | Principal descriptor for variable group permissions. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variable_group_id"></a> [variable\_group\_id](#output\_variable\_group\_id) | Variable group ID created in this example. |
| <a name="output_variable_group_name"></a> [variable\_group\_name](#output\_variable\_group\_name) | Variable group name created in this example. |
<!-- END_TF_DOCS -->