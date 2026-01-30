# Secure Artifacts Feed Example

This example demonstrates a restricted feed with reader permissions and retention controls.

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
| <a name="module_azuredevops_artifacts_feed"></a> [azuredevops\_artifacts\_feed](#module\_azuredevops\_artifacts\_feed) | git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_artifacts_feed | ADOAFv1.0.0 |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.project_collection_admins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_feed_name"></a> [feed\_name](#input\_feed\_name) | Feed name. | `string` | `"secure-feed"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_feed_id"></a> [feed\_id](#output\_feed\_id) | Feed ID created in this example. |
<!-- END_TF_DOCS -->