output "id" {
  description = "The ID of the Application Insights resource."
  value       = try(azurerm_application_insights.application_insights.id, null)
}

output "name" {
  description = "The name of the Application Insights resource."
  value       = try(azurerm_application_insights.application_insights.name, null)
}

output "location" {
  description = "The Azure region where Application Insights is deployed."
  value       = try(azurerm_application_insights.application_insights.location, null)
}

output "resource_group_name" {
  description = "The resource group name for Application Insights."
  value       = try(azurerm_application_insights.application_insights.resource_group_name, null)
}

output "application_type" {
  description = "The application type for Application Insights."
  value       = try(azurerm_application_insights.application_insights.application_type, null)
}

output "workspace_id" {
  description = "The workspace ID linked to Application Insights (if workspace-based)."
  value       = try(azurerm_application_insights.application_insights.workspace_id, null)
}

output "app_id" {
  description = "The Application Insights app ID."
  value       = try(azurerm_application_insights.application_insights.app_id, null)
}

output "instrumentation_key" {
  description = "The Application Insights instrumentation key."
  value       = try(azurerm_application_insights.application_insights.instrumentation_key, null)
  sensitive   = true
}

output "connection_string" {
  description = "The Application Insights connection string."
  value       = try(azurerm_application_insights.application_insights.connection_string, null)
  sensitive   = true
}

output "api_keys" {
  description = "API keys created for Application Insights."
  value = {
    for name, key in azurerm_application_insights_api_key.application_insights_api_key : name => {
      id                = key.id
      api_key           = key.api_key
      read_permissions  = key.read_permissions
      write_permissions = key.write_permissions
    }
  }
  sensitive = true
}

output "analytics_items" {
  description = "Analytics items created for Application Insights."
  value = {
    for name, item in azurerm_application_insights_analytics_item.application_insights_analytics_item : name => {
      id    = item.id
      name  = item.name
      type  = item.type
      scope = item.scope
    }
  }
}

output "web_tests" {
  description = "Classic web tests created for Application Insights."
  value = {
    for name, test in azurerm_application_insights_web_test.application_insights_web_test : name => {
      id   = test.id
      name = test.name
    }
  }
}

output "standard_web_tests" {
  description = "Standard web tests created for Application Insights."
  value = {
    for name, test in azurerm_application_insights_standard_web_test.application_insights_standard_web_test : name => {
      id   = test.id
      name = test.name
    }
  }
}

output "smart_detection_rules" {
  description = "Smart detection rules created for Application Insights."
  value = {
    for name, rule in azurerm_application_insights_smart_detection_rule.application_insights_smart_detection_rule : name => {
      id      = rule.id
      name    = rule.name
      enabled = rule.enabled
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value       = local.diagnostic_settings_skipped
}
