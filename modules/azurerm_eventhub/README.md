# Terraform Azure Event Hub Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages Azure Event Hubs within an existing Event Hub Namespace, including
consumer groups and authorization rules.

## Usage

```hcl
module "eventhub" {
  source = "path/to/azurerm_eventhub"

  name            = "example-eh"
  namespace_id    = azurerm_eventhub_namespace.example.id
  partition_count = 2
}
```

## Security Considerations

- Use namespace-level network restrictions and private endpoints for isolation.
- Limit authorization rule permissions to the minimum required.
- Enable capture only when required and store data in a private storage account.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a basic Event Hub in a new Event Hub Namespace.
- [Capture](examples/capture) - This example demonstrates enabling capture to Blob Storage for an Event Hub.
- [Complete](examples/complete) - This example demonstrates Event Hub capture, consumer groups, and authorization rules.
- [Consumer Groups](examples/consumer-groups) - This example demonstrates creating multiple consumer groups for an Event Hub.
- [Secure](examples/secure) - This example creates an Event Hub in a namespace with public access disabled.
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
| [azurerm_eventhub.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.authorization_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.consumer_groups](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub_consumer_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | Authorization rules for the Event Hub. | <pre>list(object({<br/>    name   = string<br/>    listen = optional(bool, false)<br/>    send   = optional(bool, false)<br/>    manage = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_capture_description"></a> [capture\_description](#input\_capture\_description) | Optional capture configuration for the Event Hub. | <pre>object({<br/>    enabled             = bool<br/>    encoding            = string<br/>    interval_in_seconds = optional(number, 300)<br/>    size_limit_in_bytes = optional(number, 314572800)<br/>    skip_empty_archives = optional(bool, false)<br/>    destination = object({<br/>      name                = optional(string, "EventHubArchive.AzureBlockBlob")<br/>      storage_account_id  = string<br/>      blob_container_name = string<br/>      archive_name_format = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_consumer_groups"></a> [consumer\_groups](#input\_consumer\_groups) | Consumer groups to create for the Event Hub. | <pre>list(object({<br/>    name          = string<br/>    user_metadata = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_message_retention"></a> [message\_retention](#input\_message\_retention) | Specifies the number of days to retain events. Valid range is 1-90 when retention\_description is not used. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Event Hub. | `string` | n/a | yes |
| <a name="input_namespace_id"></a> [namespace\_id](#input\_namespace\_id) | The ID of the Event Hub Namespace. | `string` | n/a | yes |
| <a name="input_partition_count"></a> [partition\_count](#input\_partition\_count) | Specifies the number of partitions. Valid range is 1-1024 (dedicated cluster) or 1-32 (shared). | `number` | n/a | yes |
| <a name="input_retention_description"></a> [retention\_description](#input\_retention\_description) | Optional retention description configuration for the Event Hub. | <pre>object({<br/>    cleanup_policy                    = string<br/>    retention_time_in_hours           = optional(number)<br/>    tombstone_retention_time_in_hours = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_status"></a> [status](#input\_status) | Specifies the status of the Event Hub. Possible values are Active, Disabled, SendDisabled. | `string` | `"Active"` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Custom timeouts for the Event Hub resource. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authorization_rules"></a> [authorization\_rules](#output\_authorization\_rules) | Authorization rules created for the Event Hub. |
| <a name="output_consumer_groups"></a> [consumer\_groups](#output\_consumer\_groups) | Consumer groups created for the Event Hub. |
| <a name="output_id"></a> [id](#output\_id) | The Event Hub ID. |
| <a name="output_message_retention"></a> [message\_retention](#output\_message\_retention) | The message retention (days) for the Event Hub. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Event Hub. |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The name of the Event Hub Namespace. |
| <a name="output_partition_count"></a> [partition\_count](#output\_partition\_count) | The partition count of the Event Hub. |
| <a name="output_partition_ids"></a> [partition\_ids](#output\_partition\_ids) | The identifiers for partitions created for the Event Hub. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Event Hub Namespace. |
| <a name="output_status"></a> [status](#output\_status) | The status of the Event Hub. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
