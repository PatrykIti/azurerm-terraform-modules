# Complete Security Role Assignment Example

This example assigns a role within a project scope with explicit input values.

## Usage

```bash
terraform init
terraform apply
```

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
| <a name="module_azuredevops_securityrole_assignment"></a> [azuredevops\_securityrole\_assignment](#module\_azuredevops\_securityrole\_assignment) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity_id"></a> [identity\_id](#input\_identity\_id) | Identity ID for the role assignment. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID for role assignments. | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Role name to assign. | `string` | `"Reader"` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Security role scope ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityrole_assignment_id"></a> [securityrole\_assignment\_id](#output\_securityrole\_assignment\_id) | Security role assignment ID. |
<!-- END_TF_DOCS -->
