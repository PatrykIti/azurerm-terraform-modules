# Secure Service Hooks Example

This example demonstrates a filtered webhook configuration for work item updates.

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
| <a name="module_azuredevops_servicehooks"></a> [azuredevops\_servicehooks](#module\_azuredevops\_servicehooks) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_area_path"></a> [area\_path](#input\_area\_path) | Area path for work item filters. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_webhook_url"></a> [webhook\_url](#input\_webhook\_url) | Webhook URL for service hook delivery. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_webhook_id"></a> [webhook\_id](#output\_webhook\_id) | Webhook ID created in this example. |
<!-- END_TF_DOCS -->
