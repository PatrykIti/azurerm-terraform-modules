# Complete Security Role Assignment Example

This example assigns multiple roles within a project scope.

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
| <a name="input_contributor_identity_id"></a> [contributor\_identity\_id](#input\_contributor\_identity\_id) | Identity ID for Contributor role assignment. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID for role assignments. | `string` | n/a | yes |
| <a name="input_reader_identity_id"></a> [reader\_identity\_id](#input\_reader\_identity\_id) | Identity ID for Reader role assignment. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityrole_assignment_ids"></a> [securityrole\_assignment\_ids](#output\_securityrole\_assignment\_ids) | Map of security role assignment IDs keyed by assignment key. |
<!-- END_TF_DOCS -->
