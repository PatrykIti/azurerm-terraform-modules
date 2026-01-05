# Complete Azure DevOps Project Permissions Example

This example demonstrates a full permissions map with mixed scopes and optional principal override.

## Features

- Assigns permissions at both project and collection scopes.
- Demonstrates `principal` override for a known descriptor.
- Shows multiple permission entries in a single module call.

## Prerequisites

- An existing Azure DevOps project ID (`project_id`).
- Group names or descriptors required by the fixture inputs.

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

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_project_permissions"></a> [azuredevops\_project\_permissions](#module\_azuredevops\_project\_permissions) | github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project_permissions | ADOPPv1.1.1 |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.project_collection_admins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

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
