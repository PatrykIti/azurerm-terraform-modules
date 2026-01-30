output "eventhub_id" {
  description = "The Event Hub ID."
  value       = module.eventhub.id
}

output "eventhub_name" {
  description = "The Event Hub name."
  value       = module.eventhub.name
}

output "resource_group_name" {
  description = "The resource group name for the Event Hub Namespace."
  value       = module.eventhub.resource_group_name
}
