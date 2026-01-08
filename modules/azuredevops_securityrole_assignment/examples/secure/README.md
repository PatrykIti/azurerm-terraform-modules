# Secure Security Role Assignment Example

This example assigns a minimal Reader role to a specified identity.

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
| <a name="input_identity_id"></a> [identity\_id](#input\_identity\_id) | Identity ID for the secure assignment. | `string` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | Target resource ID for the secure assignment. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityrole_assignment_id"></a> [securityrole\_assignment\_id](#output\_securityrole\_assignment\_id) | Security role assignment ID. |
<!-- END_TF_DOCS -->
