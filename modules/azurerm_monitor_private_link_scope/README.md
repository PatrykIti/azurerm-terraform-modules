# Terraform Azure Monitor Private Link Scope Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Monitor Private Link Scopes (AMPLS) with optional scoped services and diagnostic settings.

## Usage

```hcl
module "monitor_private_link_scope" {
  source = "path/to/azurerm_monitor_private_link_scope"

  name                = "example-ampls"
  resource_group_name = azurerm_resource_group.example.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"

  scoped_services = [
    {
      name               = "ampls-law"
      linked_resource_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure Monitor Private Link Scope (AMPLS) configuration.
- [Complete](examples/complete) - This example demonstrates a complete Azure Monitor Private Link Scope (AMPLS) configuration with scoped services.
- [Secure](examples/secure) - This example demonstrates a secure Azure Monitor Private Link Scope (AMPLS) configuration with PrivateOnly access modes.
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
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_private_link_scope.monitor_private_link_scope](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_private_link_scope) | resource |
| [azurerm_monitor_private_link_scoped_service.scoped_service](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_private_link_scoped_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ingestion_access_mode"></a> [ingestion\_access\_mode](#input\_ingestion\_access\_mode) | Access mode for ingestion. Possible values are PrivateOnly and Open. | `string` | `"PrivateOnly"` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for the Azure Monitor Private Link Scope.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure Monitor Private Link Scope. | `string` | n/a | yes |
| <a name="input_query_access_mode"></a> [query\_access\_mode](#input\_query\_access\_mode) | Access mode for query. Possible values are PrivateOnly and Open. | `string` | `"PrivateOnly"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Azure Monitor Private Link Scope. | `string` | n/a | yes |
| <a name="input_scoped_services"></a> [scoped\_services](#input\_scoped\_services) | Scoped services linked to the private link scope. | <pre>list(object({<br/>    name               = string<br/>    linked_resource_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Azure Monitor Private Link Scope. |
| <a name="output_ingestion_access_mode"></a> [ingestion\_access\_mode](#output\_ingestion\_access\_mode) | The ingestion access mode for the Azure Monitor Private Link Scope. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Azure Monitor Private Link Scope. |
| <a name="output_query_access_mode"></a> [query\_access\_mode](#output\_query\_access\_mode) | The query access mode for the Azure Monitor Private Link Scope. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Azure Monitor Private Link Scope. |
| <a name="output_scoped_service_ids"></a> [scoped\_service\_ids](#output\_scoped\_service\_ids) | Map of scoped service names to resource IDs. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Azure Monitor Private Link Scope. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
