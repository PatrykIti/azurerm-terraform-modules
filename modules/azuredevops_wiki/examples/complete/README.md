# Complete Wiki Example

This example demonstrates a code wiki backed by a repository with multiple pages.

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
| <a name="module_azuredevops_wiki"></a> [azuredevops\_wiki](#module\_azuredevops\_wiki) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | Repository ID for the code wiki. | `string` | n/a | yes |
| <a name="input_repository_version"></a> [repository\_version](#input\_repository\_version) | Repository branch or tag for the code wiki. | `string` | `"main"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wiki_ids"></a> [wiki\_ids](#output\_wiki\_ids) | Wiki IDs created in this example. |
| <a name="output_wiki_page_ids"></a> [wiki\_page\_ids](#output\_wiki\_page\_ids) | Wiki page IDs created in this example. |
<!-- END_TF_DOCS -->