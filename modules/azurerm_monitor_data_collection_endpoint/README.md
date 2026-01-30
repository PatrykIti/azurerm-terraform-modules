# Terraform Azure Monitor Data Collection Endpoint Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Monitor Data Collection Endpoints

## Usage

```hcl
module "azurerm_monitor_data_collection_endpoint" {
  source = "path/to/azurerm_monitor_data_collection_endpoint"

  # Required variables
  name                = "example-azurerm_monitor_data_collection_endpoint"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Monitor Data Collection Endpoint configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Monitor Data Collection Endpoint with all available features and configurations.
- [Secure](examples/secure) - This example demonstrates a security-focused Data Collection Endpoint configuration with public access disabled.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_data_collection_endpoint) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | A description for the Data Collection Endpoint. | `string` | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | The kind of the Data Collection Endpoint. Possible values are Linux or Windows. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Data Collection Endpoint should exist. | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for the Data Collection Endpoint.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Data Collection Endpoint. | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Data Collection Endpoint. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Data Collection Endpoint. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Data Collection Endpoint. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_access_endpoint"></a> [configuration\_access\_endpoint](#output\_configuration\_access\_endpoint) | The configuration access endpoint for the Data Collection Endpoint. |
| <a name="output_description"></a> [description](#output\_description) | The description of the Data Collection Endpoint. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Data Collection Endpoint. |
| <a name="output_immutable_id"></a> [immutable\_id](#output\_immutable\_id) | The immutable ID of the Data Collection Endpoint. |
| <a name="output_kind"></a> [kind](#output\_kind) | The kind of the Data Collection Endpoint. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Data Collection Endpoint. |
| <a name="output_logs_ingestion_endpoint"></a> [logs\_ingestion\_endpoint](#output\_logs\_ingestion\_endpoint) | The logs ingestion endpoint for the Data Collection Endpoint. |
| <a name="output_metrics_ingestion_endpoint"></a> [metrics\_ingestion\_endpoint](#output\_metrics\_ingestion\_endpoint) | The metrics ingestion endpoint for the Data Collection Endpoint. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Data Collection Endpoint. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Data Collection Endpoint. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Data Collection Endpoint. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
