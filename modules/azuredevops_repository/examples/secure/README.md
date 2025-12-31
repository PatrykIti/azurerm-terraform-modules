# Secure Azure DevOps Repository Example

This example demonstrates a repository with stricter review and status policies.

## Features

- Minimum reviewers policy
- Status check policy
- Work item linking policy
- Reserved names, author email pattern, and case enforcement policies

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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_repository"></a> [azuredevops\_repository](#module\_azuredevops\_repository) | git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository | ADOR1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_reviewer_count"></a> [reviewer\_count](#input\_reviewer\_count) | Minimum number of reviewers required. | `number` | `2` | no |
| <a name="input_status_check_genre"></a> [status\_check\_genre](#input\_status\_check\_genre) | Optional status check genre. | `string` | `null` | no |
| <a name="input_status_check_name"></a> [status\_check\_name](#input\_status\_check\_name) | Status check name to enforce. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_ids"></a> [branch\_ids](#output\_branch\_ids) | Map of branch IDs keyed by branch name. |
| <a name="output_policy_ids"></a> [policy\_ids](#output\_policy\_ids) | Map of policy IDs grouped by policy type. |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | Repository ID. |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | Repository web URL. |
<!-- END_TF_DOCS -->
