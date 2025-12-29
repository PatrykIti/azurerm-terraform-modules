# Complete Service Hooks Example

This example demonstrates module-level for_each for webhook and storage queue hooks with pipeline filters.

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
| <a name="input_account_key"></a> [account\_key](#input\_account\_key) | Azure Storage account key for the queue hook. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Azure Storage account name for the queue hook. | `string` | n/a | yes |
| <a name="input_pipeline_name"></a> [pipeline\_name](#input\_pipeline\_name) | Pipeline name to filter build completed events. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Azure Storage queue name for the queue hook. | `string` | n/a | yes |
| <a name="input_webhook_url"></a> [webhook\_url](#input\_webhook\_url) | Webhook URL for service hook delivery. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_queue_hook_ids"></a> [storage\_queue\_hook\_ids](#output\_storage\_queue\_hook\_ids) | Storage queue hook IDs created in this example, keyed by module instance. |
| <a name="output_webhook_ids"></a> [webhook\_ids](#output\_webhook\_ids) | Webhook IDs created in this example, keyed by module instance. |
<!-- END_TF_DOCS -->