#------------------------------------------------------------------------------
# Resource Outputs
#------------------------------------------------------------------------------
output "id" {
  description = "The ID of the MODULE_TYPE_PLACEHOLDER"
  value       = "" # TODO: Replace with actual resource ID
}

output "name" {
  description = "The name of the MODULE_TYPE_PLACEHOLDER"
  value       = var.name
}

output "resource_group_name" {
  description = "The name of the resource group containing the MODULE_TYPE_PLACEHOLDER"
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region where the MODULE_TYPE_PLACEHOLDER is located"
  value       = var.location
}

#------------------------------------------------------------------------------
# Configuration Outputs
#------------------------------------------------------------------------------
# TODO: Add outputs for important configuration values that other modules might need

#------------------------------------------------------------------------------
# Connection/Endpoint Outputs
#------------------------------------------------------------------------------
# TODO: Add any connection strings, endpoints, or URIs if applicable

#------------------------------------------------------------------------------
# Security Outputs
#------------------------------------------------------------------------------
# TODO: Add any security-related outputs (but be careful not to expose sensitive data)
# Consider using sensitive = true for sensitive outputs

#------------------------------------------------------------------------------
# Computed Outputs
#------------------------------------------------------------------------------
output "tags" {
  description = "The tags applied to the MODULE_TYPE_PLACEHOLDER"
  value       = local.tags
}