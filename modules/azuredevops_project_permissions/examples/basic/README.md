# Basic Azure DevOps Project Permissions Example

This example assigns a minimal permission set to a collection-level group by name.

## Features

- Assigns a single permission to a collection group.
- Uses group name lookup instead of hardcoded descriptors.

## Prerequisites

- An existing Azure DevOps project ID (`project_id`).
- Access to the collection group name (defaults to `Project Collection Administrators`).

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
| <a name="input_collection_group_name"></a> [collection\_group\_name](#input\_collection\_group\_name) | Collection-level group name to grant permissions. | `string` | `"Project Collection Administrators"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_ids"></a> [permission\_ids](#output\_permission\_ids) | n/a |
| <a name="output_permission_principals"></a> [permission\_principals](#output\_permission\_principals) | n/a |
<!-- END_TF_DOCS -->
