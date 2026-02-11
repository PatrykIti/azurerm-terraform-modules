# Terraform Azure Role Assignment Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages Azure RBAC role assignments.

## Usage

```hcl
module "role_assignment" {
  source = "path/to/azurerm_role_assignment"

  # Required variables
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.example.principal_id

  # Optional configuration
  principal_type = "ServicePrincipal"
  description    = "Read-only access for workload identity"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Abac Condition](examples/abac-condition) - This example assigns a role with an attribute-based access control (ABAC) condition.
- [Basic](examples/basic) - This example assigns the built-in Reader role at a resource group scope to a user-assigned managed identity.
- [Complete](examples/complete) - This example demonstrates a role assignment with explicit name, principal type, description, and ABAC condition.
- [Delegated Managed Identity](examples/delegated-managed-identity) - This example demonstrates the `delegated_managed_identity_resource_id` input.
- [Management Group Scope](examples/management-group-scope) - This example assigns the built-in Reader role at a management group scope.
- [Resource Scope](examples/resource-scope) - This example assigns the Storage Blob Data Reader role at a storage account scope.
- [Secure](examples/secure) - This example demonstrates a least-privilege role assignment using a custom role definition scoped to a single resource group.
- [Subscription Scope](examples/subscription-scope) - This example assigns the built-in Reader role at the subscription scope.
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
| [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_condition"></a> [condition](#input\_condition) | Optional condition expression for the role assignment. | `string` | `null` | no |
| <a name="input_condition_version"></a> [condition\_version](#input\_condition\_version) | Condition version. Currently only 2.0 is supported when condition is used. | `string` | `null` | no |
| <a name="input_delegated_managed_identity_resource_id"></a> [delegated\_managed\_identity\_resource\_id](#input\_delegated\_managed\_identity\_resource\_id) | Optional delegated managed identity resource ID (cross-tenant scenario). | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Optional description for the role assignment. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional role assignment name (GUID). When omitted, Azure will generate one. | `string` | `null` | no |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | The principal (object) ID to assign the role to. | `string` | n/a | yes |
| <a name="input_principal_type"></a> [principal\_type](#input\_principal\_type) | The principal type. Possible values are User, Group, or ServicePrincipal. | `string` | `null` | no |
| <a name="input_role_definition_id"></a> [role\_definition\_id](#input\_role\_definition\_id) | The ID of the role definition to assign. Exactly one of role\_definition\_id or role\_definition\_name must be set. | `string` | `null` | no |
| <a name="input_role_definition_name"></a> [role\_definition\_name](#input\_role\_definition\_name) | The built-in role definition name to assign. Exactly one of role\_definition\_id or role\_definition\_name must be set. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope at which the role assignment applies. Use a management group, subscription, resource group, or resource ID. | `string` | n/a | yes |
| <a name="input_skip_service_principal_aad_check"></a> [skip\_service\_principal\_aad\_check](#input\_skip\_service\_principal\_aad\_check) | If true, skips the AAD check for service principals during assignment. | `bool` | `false` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for role assignments. | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_condition"></a> [condition](#output\_condition) | The ABAC condition expression, if configured. |
| <a name="output_condition_version"></a> [condition\_version](#output\_condition\_version) | The ABAC condition version, if configured. |
| <a name="output_delegated_managed_identity_resource_id"></a> [delegated\_managed\_identity\_resource\_id](#output\_delegated\_managed\_identity\_resource\_id) | The delegated managed identity resource ID, if configured. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Role Assignment |
| <a name="output_name"></a> [name](#output\_name) | The name of the Role Assignment |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the Role Assignment. |
| <a name="output_principal_type"></a> [principal\_type](#output\_principal\_type) | The principal type assigned. |
| <a name="output_role_definition_id"></a> [role\_definition\_id](#output\_role\_definition\_id) | The role definition ID assigned. |
| <a name="output_role_definition_name"></a> [role\_definition\_name](#output\_role\_definition\_name) | The role definition name assigned (if using role\_definition\_name). |
| <a name="output_scope"></a> [scope](#output\_scope) | The scope for the Role Assignment. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
