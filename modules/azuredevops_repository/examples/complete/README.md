# Complete Azure DevOps Repository Example

This example demonstrates managing multiple repositories (via module-level for_each) with branches, permissions, and a selection of branch/repository policies.

## Features

- Two repositories with clean initialization (module-level for_each)
- Additional branch created from default branch
- Git permissions for a group principal
- Branch policies (minimum reviewers, build validation)
- Repository policies (author email pattern, reserved names)

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
| <a name="module_azuredevops_repository"></a> [azuredevops\_repository](#module\_azuredevops\_repository) | git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository | ADORv1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_author_email_patterns"></a> [author\_email\_patterns](#input\_author\_email\_patterns) | Allowed author email patterns for commits. | `list(string)` | <pre>[<br/>  "*@example.com"<br/>]</pre> | no |
| <a name="input_build_definition_id"></a> [build\_definition\_id](#input\_build\_definition\_id) | Build definition ID for build validation policy. | `string` | n/a | yes |
| <a name="input_principal_descriptor"></a> [principal\_descriptor](#input\_principal\_descriptor) | Descriptor of the group used for git permissions. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_reviewer_count"></a> [reviewer\_count](#input\_reviewer\_count) | Minimum number of reviewers required. | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_ids"></a> [branch\_ids](#output\_branch\_ids) | Map of branch ID maps keyed by module instance key. |
| <a name="output_file_ids"></a> [file\_ids](#output\_file\_ids) | Map of file ID maps keyed by module instance key. |
| <a name="output_policy_ids"></a> [policy\_ids](#output\_policy\_ids) | Map of policy ID maps keyed by module instance key. |
| <a name="output_repository_ids"></a> [repository\_ids](#output\_repository\_ids) | Map of repository IDs keyed by module instance key. |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Map of repository URLs keyed by module instance key. |
<!-- END_TF_DOCS -->
