# Secure Azure DevOps Environments Example

This example demonstrates environment approvals, exclusive locks, and business hours.

## Features

- Approval checks for controlled deployments
- Exclusive lock to prevent concurrent releases
- Business hours gating for release windows

## Usage

```bash
terraform init
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
| <a name="module_azuredevops_environments"></a> [azuredevops\_environments](#module\_azuredevops\_environments) | git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_environments | ADOEv1.0.0 |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.project_collection_admins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_check_ids"></a> [check\_ids](#output\_check\_ids) | Check IDs created by the module. |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | Environment ID created by the module. |
<!-- END_TF_DOCS -->
