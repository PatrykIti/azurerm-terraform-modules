# Terraform Azure Role Definition Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages custom Azure RBAC role definitions.

## Usage

```hcl
module "role_definition" {
  source = "path/to/azurerm_role_definition"

  # Required variables
  name  = "custom-role"
  scope = data.azurerm_subscription.current.id

  permissions = [
    {
      actions = [
        "Microsoft.Resources/subscriptions/resourceGroups/read"
      ]
    }
  ]

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a minimal custom role definition scoped to the current subscription.
- [Complete](examples/complete) - This example demonstrates a custom role definition with management and data actions.
- [Secure](examples/secure) - This example demonstrates a least-privilege role definition scoped to a single resource group.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition.role_definition](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/role_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes) | List of scopes at which the role definition is assignable. | `list(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Optional description of the role definition. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The display name of the role definition. | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of permission blocks defining actions and data actions for the role. | <pre>list(object({<br/>    actions          = optional(list(string), [])<br/>    not_actions      = optional(list(string), [])<br/>    data_actions     = optional(list(string), [])<br/>    not_data_actions = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_role_definition_id"></a> [role\_definition\_id](#input\_role\_definition\_id) | Optional role definition ID (GUID). When omitted, Azure will generate one. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope at which the role definition is created (management group, subscription, or resource group). | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for role definitions. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_assignable_scopes"></a> [assignable\_scopes](#output\_assignable\_scopes) | The scopes where the role definition can be assigned. |
| <a name="output_description"></a> [description](#output\_description) | The role definition description. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Role Definition |
| <a name="output_name"></a> [name](#output\_name) | The name of the Role Definition |
| <a name="output_role_definition_id"></a> [role\_definition\_id](#output\_role\_definition\_id) | The role definition ID (GUID). |
| <a name="output_scope"></a> [scope](#output\_scope) | The scope at which the role definition is created. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
