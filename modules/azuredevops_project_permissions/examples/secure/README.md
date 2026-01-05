# Secure Azure DevOps Project Permissions Example

This example demonstrates least-privilege permission assignments for project-level groups.

## Features

- Grants only required read permissions.
- Avoids broad or write-level permissions.
- Uses group name lookup to keep descriptors out of configuration.

## Prerequisites

- An existing Azure DevOps project ID (`project_id`).
- Access to the target group name used in the example variables.

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
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
| <a name="module_azuredevops_project_permissions"></a> [azuredevops\_project\_permissions](#module\_azuredevops\_project\_permissions) | github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project_permissions | ADOPPv1.1.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_group_name"></a> [project\_group\_name](#input\_project\_group\_name) | Project-scoped group name to grant permissions. | `string` | `"Readers"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_ids"></a> [permission\_ids](#output\_permission\_ids) | n/a |
| <a name="output_permission_principals"></a> [permission\_principals](#output\_permission\_principals) | n/a |
<!-- END_TF_DOCS -->
