# Complete Azure DevOps Team Example

This example demonstrates module-level for_each with memberships and administrators.

## Features

- Creates multiple Azure DevOps teams
- Adds members and administrators via group descriptors
- Uses module-level for_each to manage multiple teams

## Key Configuration

Use this example to model team structures with shared membership groups.

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
| [azuredevops_group.project_collection_valid_users](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_team_name_prefix"></a> [team\_name\_prefix](#input\_team\_name\_prefix) | Prefix for the team name. | `string` | `"ado-team-complete-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_team_administrator_ids"></a> [team\_administrator\_ids](#output\_team\_administrator\_ids) | Map of team administrator assignment IDs keyed by team key. |
| <a name="output_team_descriptors"></a> [team\_descriptors](#output\_team\_descriptors) | Map of team descriptors keyed by team key. |
| <a name="output_team_ids"></a> [team\_ids](#output\_team\_ids) | Map of team IDs keyed by team key. |
| <a name="output_team_member_ids"></a> [team\_member\_ids](#output\_team\_member\_ids) | Map of team membership IDs keyed by team key. |
<!-- END_TF_DOCS -->
