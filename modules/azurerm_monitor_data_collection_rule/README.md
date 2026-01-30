# Terraform Azure Monitor Data Collection Rule Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages Azure Monitor Data Collection Rules

## Usage

```hcl
module "azurerm_monitor_data_collection_endpoint" {
  source = "path/to/azurerm_monitor_data_collection_endpoint"

  name                = "example-dce"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Windows"
}

module "azurerm_monitor_data_collection_rule" {
  source = "path/to/azurerm_monitor_data_collection_rule"

  # Required variables and minimum configuration
  name                = "example-dcr"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Windows"

  # Required when data_sources are configured
  data_collection_endpoint_id = module.azurerm_monitor_data_collection_endpoint.id

  destinations = {
    log_analytics = [
      {
        name                  = "log-analytics"
        workspace_resource_id = azurerm_log_analytics_workspace.example.id
      }
    ]
  }

  data_sources = {
    windows_event_log = [
      {
        name           = "windows-events"
        streams        = ["Microsoft-Event"]
        x_path_queries = ["Application!*[System[(Level=1 or Level=2)]]"]
      }
    ]
  }

  data_flows = [
    {
      streams      = ["Microsoft-Event"]
      destinations = ["log-analytics"]
    }
  ]

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Aks Advanced](examples/aks-advanced) - This example demonstrates an advanced Container Insights Data Collection Rule (DCR) for AKS using the "advanced" stream profile.
- [Aks Basic](examples/aks-basic) - This example demonstrates a basic Container Insights Data Collection Rule (DCR) for AKS using the "basic" stream profile.
- [Basic](examples/basic) - This example demonstrates a basic Monitor Data Collection Rule configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Monitor Data Collection Rule with all available features and configurations.
- [Secure](examples/secure) - This example demonstrates a DCR configured to use a dedicated Data Collection Endpoint with public access disabled on the endpoint.
- [Syslog](examples/syslog) - This example demonstrates a Data Collection Rule configured for Linux syslog data.
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
| [azurerm_monitor_data_collection_rule.monitor_data_collection_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.monitor_data_collection_rule_association](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associations"></a> [associations](#input\_associations) | Associations between this Data Collection Rule and target resources.<br/><br/>Each entry links the rule to a target resource (for example, AKS or a VM). | <pre>list(object({<br/>    name               = string<br/>    target_resource_id = string<br/>    description        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_data_collection_endpoint_id"></a> [data\_collection\_endpoint\_id](#input\_data\_collection\_endpoint\_id) | The resource ID of the Data Collection Endpoint this rule can be used with. | `string` | `null` | no |
| <a name="input_data_flows"></a> [data\_flows](#input\_data\_flows) | Data flow configuration for the Data Collection Rule. | <pre>list(object({<br/>    streams            = list(string)<br/>    destinations       = list(string)<br/>    built_in_transform = optional(string)<br/>    output_stream      = optional(string)<br/>    transform_kql      = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_data_sources"></a> [data\_sources](#input\_data\_sources) | Data sources configuration for the Data Collection Rule. | <pre>object({<br/>    data_import = optional(object({<br/>      event_hub_data_source = object({<br/>        name           = string<br/>        stream         = string<br/>        consumer_group = optional(string)<br/>      })<br/>    }))<br/>    extension = optional(list(object({<br/>      name               = string<br/>      extension_name     = string<br/>      streams            = list(string)<br/>      input_data_sources = optional(list(string))<br/>      extension_json     = optional(string)<br/>    })), [])<br/>    iis_log = optional(list(object({<br/>      name            = string<br/>      streams         = list(string)<br/>      log_directories = list(string)<br/>    })), [])<br/>    log_file = optional(list(object({<br/>      name          = string<br/>      streams       = list(string)<br/>      file_patterns = list(string)<br/>      format        = string<br/>      settings = optional(object({<br/>        text = object({<br/>          record_start_timestamp_format = string<br/>        })<br/>      }))<br/>    })), [])<br/>    performance_counter = optional(list(object({<br/>      name                          = string<br/>      streams                       = list(string)<br/>      counter_specifiers            = list(string)<br/>      sampling_frequency_in_seconds = number<br/>    })), [])<br/>    platform_telemetry = optional(list(object({<br/>      name    = string<br/>      streams = list(string)<br/>    })), [])<br/>    prometheus_forwarder = optional(list(object({<br/>      name    = string<br/>      streams = list(string)<br/>      label_include_filter = optional(list(object({<br/>        label = string<br/>        value = string<br/>      })), [])<br/>    })), [])<br/>    syslog = optional(list(object({<br/>      name           = string<br/>      facility_names = list(string)<br/>      log_levels     = list(string)<br/>      streams        = list(string)<br/>    })), [])<br/>    windows_event_log = optional(list(object({<br/>      name           = string<br/>      streams        = list(string)<br/>      x_path_queries = list(string)<br/>    })), [])<br/>    windows_firewall_log = optional(list(object({<br/>      name    = string<br/>      streams = list(string)<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | A description for the Data Collection Rule. | `string` | `null` | no |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | Destination configuration for the Data Collection Rule. | <pre>object({<br/>    azure_monitor_metrics = optional(object({<br/>      name = string<br/>    }))<br/>    event_hub = optional(list(object({<br/>      name         = string<br/>      event_hub_id = string<br/>    })), [])<br/>    event_hub_direct = optional(list(object({<br/>      name         = string<br/>      event_hub_id = string<br/>    })), [])<br/>    log_analytics = optional(list(object({<br/>      name                  = string<br/>      workspace_resource_id = string<br/>    })), [])<br/>    monitor_account = optional(list(object({<br/>      name               = string<br/>      monitor_account_id = string<br/>    })), [])<br/>    storage_blob = optional(list(object({<br/>      name               = string<br/>      storage_account_id = string<br/>      container_name     = string<br/>    })), [])<br/>    storage_blob_direct = optional(list(object({<br/>      name               = string<br/>      storage_account_id = string<br/>      container_name     = string<br/>    })), [])<br/>    storage_table_direct = optional(list(object({<br/>      name               = string<br/>      storage_account_id = string<br/>      table_name         = string<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed Service Identity configuration for the Data Collection Rule. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | The kind of the Data Collection Rule. Possible values are Linux, Windows, AgentDirectToStore, and WorkspaceTransforms. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Data Collection Rule should exist. | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for the Data Collection Rule.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Data Collection Rule. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Data Collection Rule. | `string` | n/a | yes |
| <a name="input_stream_declarations"></a> [stream\_declarations](#input\_stream\_declarations) | Custom stream declarations for the Data Collection Rule. | <pre>list(object({<br/>    stream_name = string<br/>    columns = list(object({<br/>      name = string<br/>      type = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Data Collection Rule. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_associations"></a> [associations](#output\_associations) | Data Collection Rule associations created by the module. |
| <a name="output_data_collection_endpoint_id"></a> [data\_collection\_endpoint\_id](#output\_data\_collection\_endpoint\_id) | The Data Collection Endpoint ID used by the rule. |
| <a name="output_description"></a> [description](#output\_description) | The description of the Data Collection Rule. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Data Collection Rule. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity details for the Data Collection Rule. |
| <a name="output_immutable_id"></a> [immutable\_id](#output\_immutable\_id) | The immutable ID of the Data Collection Rule. |
| <a name="output_kind"></a> [kind](#output\_kind) | The kind of the Data Collection Rule. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Data Collection Rule. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Data Collection Rule. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Data Collection Rule. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Data Collection Rule. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
