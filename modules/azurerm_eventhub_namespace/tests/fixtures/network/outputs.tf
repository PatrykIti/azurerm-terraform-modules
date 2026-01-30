output "eventhub_namespace_id" {
  description = "The ID of the Event Hub Namespace."
  value       = module.eventhub_namespace.id
}

output "eventhub_namespace_name" {
  description = "The name of the Event Hub Namespace."
  value       = module.eventhub_namespace.name
}

output "resource_group_name" {
  description = "The resource group name for the Event Hub Namespace."
  value       = module.eventhub_namespace.resource_group_name
}
