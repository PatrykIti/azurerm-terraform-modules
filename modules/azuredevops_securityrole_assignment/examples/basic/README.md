# Basic Security Role Assignment Example

This example assigns a Reader role to a provided identity within a project scope.

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
| <a name="input_identity_id"></a> [identity\_id](#input\_identity\_id) | Identity descriptor/ID to assign the role to. | `string` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | Target resource ID for the role assignment. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityrole_assignment_ids"></a> [securityrole\_assignment\_ids](#output\_securityrole\_assignment\_ids) | Map of security role assignment IDs keyed by assignment key. |
<!-- END_TF_DOCS -->
