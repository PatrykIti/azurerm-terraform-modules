output "id" {
  description = "The Event Hub ID."
  value       = azurerm_eventhub.eventhub.id
}

output "name" {
  description = "The name of the Event Hub."
  value       = azurerm_eventhub.eventhub.name
}

output "namespace_name" {
  description = "The name of the Event Hub Namespace."
  value       = local.namespace_name_effective
}

output "resource_group_name" {
  description = "The resource group name of the Event Hub Namespace."
  value       = local.resource_group_name_effective
}

output "partition_count" {
  description = "The partition count of the Event Hub."
  value       = azurerm_eventhub.eventhub.partition_count
}

output "message_retention" {
  description = "The message retention (days) for the Event Hub."
  value       = azurerm_eventhub.eventhub.message_retention
}

output "status" {
  description = "The status of the Event Hub."
  value       = azurerm_eventhub.eventhub.status
}

output "partition_ids" {
  description = "The identifiers for partitions created for the Event Hub."
  value       = azurerm_eventhub.eventhub.partition_ids
}

output "authorization_rules" {
  description = "Authorization rules created for the Event Hub."
  value = {
    for name, rule in azurerm_eventhub_authorization_rule.authorization_rules : name => {
      id                                = rule.id
      listen                            = rule.listen
      send                              = rule.send
      manage                            = rule.manage
      primary_connection_string         = rule.primary_connection_string
      primary_connection_string_alias   = rule.primary_connection_string_alias
      primary_key                       = rule.primary_key
      secondary_connection_string       = rule.secondary_connection_string
      secondary_connection_string_alias = rule.secondary_connection_string_alias
      secondary_key                     = rule.secondary_key
    }
  }
  sensitive = true
}

output "consumer_groups" {
  description = "Consumer groups created for the Event Hub."
  value = {
    for name, group in azurerm_eventhub_consumer_group.consumer_groups : name => {
      id            = group.id
      user_metadata = group.user_metadata
    }
  }
}
