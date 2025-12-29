# Secure Azure DevOps Team Example

This example demonstrates a security-focused team configuration.

## Features

- Creates a security team with strict administrator assignment
- Uses overwrite mode to avoid unintended admin access

## Key Configuration

Use this example for strict admin control and access reviews.

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
| <a name="module_azuredevops_team"></a> [azuredevops\_team](#module\_azuredevops\_team) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.project_collection_admins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Name of the team. | `string` | `"ado-team-secure-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_team_administrator_ids"></a> [team\_administrator\_ids](#output\_team\_administrator\_ids) | Map of team administrator assignment IDs keyed by admin key. |
| <a name="output_team_descriptor"></a> [team\_descriptor](#output\_team\_descriptor) | Descriptor of the Azure DevOps team. |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | ID of the Azure DevOps team. |
<!-- END_TF_DOCS -->
