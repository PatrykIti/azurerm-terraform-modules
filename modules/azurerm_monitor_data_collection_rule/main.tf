locals {
  destination_names = compact(concat(
    var.destinations.azure_monitor_metrics == null ? [] : [var.destinations.azure_monitor_metrics.name],
    [for d in try(var.destinations.event_hub, []) : d.name],
    [for d in try(var.destinations.event_hub_direct, []) : d.name],
    [for d in try(var.destinations.log_analytics, []) : d.name],
    [for d in try(var.destinations.monitor_account, []) : d.name],
    [for d in try(var.destinations.storage_blob, []) : d.name],
    [for d in try(var.destinations.storage_blob_direct, []) : d.name],
    [for d in try(var.destinations.storage_table_direct, []) : d.name]
  ))
}

resource "azurerm_monitor_data_collection_rule" "monitor_data_collection_rule" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.description
  kind                = var.kind

  data_collection_endpoint_id = var.data_collection_endpoint_id

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  destinations {
    dynamic "azure_monitor_metrics" {
      for_each = var.destinations.azure_monitor_metrics == null ? [] : [var.destinations.azure_monitor_metrics]
      content {
        name = azure_monitor_metrics.value.name
      }
    }

    dynamic "event_hub" {
      for_each = try(var.destinations.event_hub, [])
      content {
        name         = event_hub.value.name
        event_hub_id = event_hub.value.event_hub_id
      }
    }

    dynamic "event_hub_direct" {
      for_each = try(var.destinations.event_hub_direct, [])
      content {
        name         = event_hub_direct.value.name
        event_hub_id = event_hub_direct.value.event_hub_id
      }
    }

    dynamic "log_analytics" {
      for_each = try(var.destinations.log_analytics, [])
      content {
        name                  = log_analytics.value.name
        workspace_resource_id = log_analytics.value.workspace_resource_id
      }
    }

    dynamic "monitor_account" {
      for_each = try(var.destinations.monitor_account, [])
      content {
        name               = monitor_account.value.name
        monitor_account_id = monitor_account.value.monitor_account_id
      }
    }

    dynamic "storage_blob" {
      for_each = try(var.destinations.storage_blob, [])
      content {
        name               = storage_blob.value.name
        storage_account_id = storage_blob.value.storage_account_id
        container_name     = storage_blob.value.container_name
      }
    }

    dynamic "storage_blob_direct" {
      for_each = try(var.destinations.storage_blob_direct, [])
      content {
        name               = storage_blob_direct.value.name
        storage_account_id = storage_blob_direct.value.storage_account_id
        container_name     = storage_blob_direct.value.container_name
      }
    }

    dynamic "storage_table_direct" {
      for_each = try(var.destinations.storage_table_direct, [])
      content {
        name               = storage_table_direct.value.name
        storage_account_id = storage_table_direct.value.storage_account_id
        table_name         = storage_table_direct.value.table_name
      }
    }
  }

  dynamic "data_flow" {
    for_each = var.data_flows
    content {
      streams            = data_flow.value.streams
      destinations       = data_flow.value.destinations
      built_in_transform = try(data_flow.value.built_in_transform, null)
      output_stream      = try(data_flow.value.output_stream, null)
      transform_kql      = try(data_flow.value.transform_kql, null)
    }
  }

  dynamic "data_sources" {
    for_each = var.data_sources == null ? [] : [var.data_sources]
    content {
      dynamic "data_import" {
        for_each = data_sources.value.data_import == null ? [] : [data_sources.value.data_import]
        content {
          event_hub_data_source {
            name           = data_import.value.event_hub_data_source.name
            stream         = data_import.value.event_hub_data_source.stream
            consumer_group = try(data_import.value.event_hub_data_source.consumer_group, null)
          }
        }
      }

      dynamic "extension" {
        for_each = try(data_sources.value.extension, [])
        content {
          name               = extension.value.name
          extension_name     = extension.value.extension_name
          streams            = extension.value.streams
          extension_json     = try(extension.value.extension_json, null)
          input_data_sources = try(extension.value.input_data_sources, null)
        }
      }

      dynamic "iis_log" {
        for_each = try(data_sources.value.iis_log, [])
        content {
          name            = iis_log.value.name
          streams         = iis_log.value.streams
          log_directories = iis_log.value.log_directories
        }
      }

      dynamic "log_file" {
        for_each = try(data_sources.value.log_file, [])
        content {
          name          = log_file.value.name
          streams       = log_file.value.streams
          file_patterns = log_file.value.file_patterns
          format        = log_file.value.format

          dynamic "settings" {
            for_each = log_file.value.settings == null ? [] : [log_file.value.settings]
            content {
              text {
                record_start_timestamp_format = settings.value.text.record_start_timestamp_format
              }
            }
          }
        }
      }

      dynamic "performance_counter" {
        for_each = try(data_sources.value.performance_counter, [])
        content {
          name                          = performance_counter.value.name
          streams                       = performance_counter.value.streams
          counter_specifiers            = performance_counter.value.counter_specifiers
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
        }
      }

      dynamic "platform_telemetry" {
        for_each = try(data_sources.value.platform_telemetry, [])
        content {
          name    = platform_telemetry.value.name
          streams = platform_telemetry.value.streams
        }
      }

      dynamic "prometheus_forwarder" {
        for_each = try(data_sources.value.prometheus_forwarder, [])
        content {
          name    = prometheus_forwarder.value.name
          streams = prometheus_forwarder.value.streams

          dynamic "label_include_filter" {
            for_each = try(prometheus_forwarder.value.label_include_filter, [])
            content {
              label = label_include_filter.value.label
              value = label_include_filter.value.value
            }
          }
        }
      }

      dynamic "syslog" {
        for_each = try(data_sources.value.syslog, [])
        content {
          name           = syslog.value.name
          facility_names = syslog.value.facility_names
          log_levels     = syslog.value.log_levels
          streams        = syslog.value.streams
        }
      }

      dynamic "windows_event_log" {
        for_each = try(data_sources.value.windows_event_log, [])
        content {
          name          = windows_event_log.value.name
          streams       = windows_event_log.value.streams
          x_path_queries = windows_event_log.value.x_path_queries
        }
      }

      dynamic "windows_firewall_log" {
        for_each = try(data_sources.value.windows_firewall_log, [])
        content {
          name    = windows_firewall_log.value.name
          streams = windows_firewall_log.value.streams
        }
      }
    }
  }

  dynamic "stream_declaration" {
    for_each = var.stream_declarations
    content {
      stream_name = stream_declaration.value.stream_name

      dynamic "column" {
        for_each = stream_declaration.value.columns
        content {
          name = column.value.name
          type = column.value.type
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = alltrue([for df in var.data_flows : alltrue([for d in df.destinations : contains(local.destination_names, d)])])
      error_message = "Each data_flow destination must reference a name defined in destinations."
    }
  }
}
