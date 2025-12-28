# Terraform Azure DevOps Variable Groups Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps variable groups module for managing variables, permissions, and optional Key Vault integration.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "path/to/azuredevops_variable_groups"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "shared-vars"

  description  = "Shared variables"
  allow_access = true

  variables = [
    {
      name  = "environment"
      value = "dev"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a single variable group with plain variables.
- [Complete](examples/complete) - This example demonstrates a variable group with Key Vault integration, variable group permissions, and library permissions.
- [Secure](examples/secure) - This example demonstrates a restricted variable group with secret values and minimal permissions.
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
| [azuredevops_library_permissions.library_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/library_permissions) | resource |
| [azuredevops_variable_group.variable_group](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/variable_group) | resource |
| [azuredevops_variable_group_permissions.variable_group_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/variable_group_permissions) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_access"></a> [allow\_access](#input\_allow\_access) | Whether pipelines can access the variable group without explicit authorization. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Azure DevOps variable group. | `string` | `null` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Optional Key Vault configuration for the variable group. | <pre>object({<br/>    name                = string<br/>    service_endpoint_id = string<br/>    search_depth        = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_library_permissions"></a> [library\_permissions](#input\_library\_permissions) | List of library permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure DevOps variable group. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_variable_group_permissions"></a> [variable\_group\_permissions](#input\_variable\_group\_permissions) | List of variable group permissions to assign. If variable\_group\_id is omitted, the module variable group is used. | <pre>list(object({<br/>    key               = optional(string)<br/>    variable_group_id = optional(string)<br/>    principal         = string<br/>    permissions       = map(string)<br/>    replace           = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | List of variables to store in the variable group. | <pre>list(object({<br/>    name         = string<br/>    value        = optional(string)<br/>    secret_value = optional(string)<br/>    is_secret    = optional(bool)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variable_group_id"></a> [variable\_group\_id](#output\_variable\_group\_id) | The ID of the Azure DevOps variable group. |
| <a name="output_variable_group_name"></a> [variable\_group\_name](#output\_variable\_group\_name) | The name of the Azure DevOps variable group. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/IMPORT.md](docs/IMPORT.md) - Import existing variable groups and permissions into the module
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
