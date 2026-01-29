# Terraform Azure Log Analytics Workspace Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Log Analytics workspaces

## Usage

```hcl
module "azurerm_log_analytics_workspace" {
  source = "path/to/azurerm_log_analytics_workspace"

  # Required variables
  name                = "example-azurerm_log_analytics_workspace"
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
- [Basic](examples/basic) - This example demonstrates a basic Log Analytics Workspace configuration using secure defaults and minimal setup.
- [Cluster Cmk](examples/cluster-cmk) - This example configures a customer-managed key for a Log Analytics cluster.
- [Clusters](examples/clusters) - This example provisions a Log Analytics cluster alongside the workspace.
- [Complete](examples/complete) - This example demonstrates a comprehensive Log Analytics Workspace configuration with quotas and diagnostic settings.
- [Data Export Rules](examples/data-export-rules) - This example demonstrates exporting Log Analytics tables to a storage account.
- [Linked Services](examples/linked-services) - This example links an Automation Account to a Log Analytics workspace.
- [Secure](examples/secure) - This example demonstrates a security-focused Log Analytics Workspace configuration.
- [Solutions](examples/solutions) - This example demonstrates deploying Log Analytics solutions in a workspace.
- [Storage Insights](examples/storage-insights) - This example configures a storage insights connection for a Log Analytics workspace.
- [Windows Event Datasource](examples/windows-event-datasource) - This example configures Windows Event Log ingestion for a Log Analytics workspace.
- [Windows Performance Counter](examples/windows-performance-counter) - This example configures Windows Performance Counter ingestion for a Log Analytics workspace.
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
| [azurerm_log_analytics_cluster.log_analytics_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_cluster) | resource |
| [azurerm_log_analytics_cluster_customer_managed_key.log_analytics_cluster_customer_managed_key](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_cluster_customer_managed_key) | resource |
| [azurerm_log_analytics_data_export_rule.log_analytics_data_export_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_data_export_rule) | resource |
| [azurerm_log_analytics_datasource_windows_event.log_analytics_datasource_windows_event](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_datasource_windows_event) | resource |
| [azurerm_log_analytics_datasource_windows_performance_counter.log_analytics_datasource_windows_performance_counter](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_datasource_windows_performance_counter) | resource |
| [azurerm_log_analytics_linked_service.log_analytics_linked_service](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_linked_service) | resource |
| [azurerm_log_analytics_solution.log_analytics_solution](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_storage_insights.log_analytics_storage_insights](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_storage_insights) | resource |
| [azurerm_log_analytics_workspace.log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_resource_only_permissions"></a> [allow\_resource\_only\_permissions](#input\_allow\_resource\_only\_permissions) | Whether to allow resource-only permissions for the workspace. | `bool` | `null` | no |
| <a name="input_cluster_customer_managed_keys"></a> [cluster\_customer\_managed\_keys](#input\_cluster\_customer\_managed\_keys) | Customer managed keys for Log Analytics clusters. | <pre>list(object({<br/>    name                     = string<br/>    log_analytics_cluster_id = optional(string)<br/>    cluster_name             = optional(string)<br/>    key_vault_key_id         = string<br/>  }))</pre> | `[]` | no |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Log Analytics clusters to create. | <pre>list(object({<br/>    name                = string<br/>    location            = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string), {})<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | Daily data ingestion cap in GB. Use -1 for unlimited or null to use provider defaults. | `number` | `null` | no |
| <a name="input_data_export_rules"></a> [data\_export\_rules](#input\_data\_export\_rules) | Data export rules for the workspace. | <pre>list(object({<br/>    name                    = string<br/>    destination_resource_id = string<br/>    table_names             = list(string)<br/>    enabled                 = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the Log Analytics Workspace. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Whether data ingestion from the internet is enabled. | `bool` | `true` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Whether queries from the internet are enabled. | `bool` | `true` | no |
| <a name="input_linked_services"></a> [linked\_services](#input\_linked\_services) | Linked services for the workspace (e.g., Automation Account). | <pre>list(object({<br/>    name            = string<br/>    read_access_id  = string<br/>    write_access_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether local (workspace key) authentication is enabled. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Log Analytics Workspace should exist. | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for Log Analytics Workspace diagnostics.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Log Analytics Workspace. | `string` | n/a | yes |
| <a name="input_reservation_capacity_in_gb_per_day"></a> [reservation\_capacity\_in\_gb\_per\_day](#input\_reservation\_capacity\_in\_gb\_per\_day) | Reserved capacity in GB per day for CapacityReservation SKU. | `number` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Log Analytics Workspace. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The retention period for data stored in the Log Analytics Workspace. | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU for the Log Analytics Workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_solutions"></a> [solutions](#input\_solutions) | Log Analytics solutions to deploy in the workspace. | <pre>list(object({<br/>    name = string<br/>    plan = object({<br/>      publisher       = string<br/>      product         = string<br/>      promotion_code  = optional(string)<br/>    })<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_insights"></a> [storage\_insights](#input\_storage\_insights) | Storage insights configurations for the workspace. | <pre>list(object({<br/>    name                 = string<br/>    storage_account_id   = string<br/>    storage_account_key  = string<br/>    blob_container_names = optional(list(string))<br/>    table_names          = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for Log Analytics Workspace. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_windows_event_datasources"></a> [windows\_event\_datasources](#input\_windows\_event\_datasources) | Windows Event Log data sources. | <pre>list(object({<br/>    name           = string<br/>    event_log_name = string<br/>    event_types    = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_windows_performance_counters"></a> [windows\_performance\_counters](#input\_windows\_performance\_counters) | Windows Performance Counter data sources. | <pre>list(object({<br/>    name             = string<br/>    object_name      = string<br/>    instance_name    = string<br/>    counter_name     = string<br/>    interval_seconds = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_customer_managed_keys"></a> [cluster\_customer\_managed\_keys](#output\_cluster\_customer\_managed\_keys) | Customer managed keys configured for Log Analytics clusters. |
| <a name="output_clusters"></a> [clusters](#output\_clusters) | Log Analytics clusters created by the module. |
| <a name="output_daily_quota_gb"></a> [daily\_quota\_gb](#output\_daily\_quota\_gb) | The daily quota in GB for the Log Analytics Workspace. |
| <a name="output_data_export_rules"></a> [data\_export\_rules](#output\_data\_export\_rules) | Data export rules created for the workspace. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Log Analytics Workspace. |
| <a name="output_linked_services"></a> [linked\_services](#output\_linked\_services) | Linked services created for the workspace. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Log Analytics Workspace. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Log Analytics Workspace. |
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | The primary shared key for the Log Analytics Workspace. |
| <a name="output_reservation_capacity_in_gb_per_day"></a> [reservation\_capacity\_in\_gb\_per\_day](#output\_reservation\_capacity\_in\_gb\_per\_day) | The reservation capacity in GB per day for the Log Analytics Workspace. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Log Analytics Workspace. |
| <a name="output_retention_in_days"></a> [retention\_in\_days](#output\_retention\_in\_days) | The retention period in days for the Log Analytics Workspace. |
| <a name="output_secondary_shared_key"></a> [secondary\_shared\_key](#output\_secondary\_shared\_key) | The secondary shared key for the Log Analytics Workspace. |
| <a name="output_sku"></a> [sku](#output\_sku) | The SKU of the Log Analytics Workspace. |
| <a name="output_solutions"></a> [solutions](#output\_solutions) | Log Analytics solutions created for the workspace. |
| <a name="output_storage_insights"></a> [storage\_insights](#output\_storage\_insights) | Storage insights configurations created for the workspace. |
| <a name="output_windows_event_datasources"></a> [windows\_event\_datasources](#output\_windows\_event\_datasources) | Windows Event Log data sources created for the workspace. |
| <a name="output_windows_performance_counters"></a> [windows\_performance\_counters](#output\_windows\_performance\_counters) | Windows Performance Counter data sources created for the workspace. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Workspace ID (customer ID) of the Log Analytics Workspace. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
