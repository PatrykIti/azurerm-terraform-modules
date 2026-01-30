output "id" {
  description = "The ID of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.id, null)
}

output "name" {
  description = "The name of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.name, null)
}

output "location" {
  description = "The location of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.location, null)
}

output "resource_group_name" {
  description = "The resource group name of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.resource_group_name, null)
}

output "kind" {
  description = "The kind of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.kind, null)
}

output "sku_name" {
  description = "The SKU name of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.sku_name, null)
}

output "endpoint" {
  description = "The endpoint of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.endpoint, null)
}

output "custom_subdomain_name" {
  description = "The custom subdomain name of the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.custom_subdomain_name, null)
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Cognitive Account."
  value       = try(azurerm_cognitive_account.cognitive_account.public_network_access_enabled, null)
}

output "identity" {
  description = "The managed identity of the Cognitive Account (if configured)."
  value       = try(azurerm_cognitive_account.cognitive_account.identity[0], null)
}

output "primary_access_key" {
  description = "The primary access key for the Cognitive Account (null when local auth is disabled)."
  value       = var.local_auth_enabled ? try(azurerm_cognitive_account.cognitive_account.primary_access_key, null) : null
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Cognitive Account (null when local auth is disabled)."
  value       = var.local_auth_enabled ? try(azurerm_cognitive_account.cognitive_account.secondary_access_key, null) : null
  sensitive   = true
}

output "deployments" {
  description = "OpenAI deployments created by the module."
  value = {
    for name, deployment in azurerm_cognitive_deployment.cognitive_deployment : name => {
      id   = deployment.id
      name = deployment.name
    }
  }
}

output "rai_policies" {
  description = "RAI policies created by the module."
  value = {
    for name, policy in azurerm_cognitive_account_rai_policy.rai_policy : name => {
      id   = policy.id
      name = policy.name
    }
  }
}

output "rai_blocklists" {
  description = "RAI blocklists created by the module."
  value = {
    for name, blocklist in azurerm_cognitive_account_rai_blocklist.rai_blocklist : name => {
      id   = blocklist.id
      name = blocklist.name
    }
  }
}

output "customer_managed_key_id" {
  description = "The ID of the Customer Managed Key resource when managed separately."
  value       = try(azurerm_cognitive_account_customer_managed_key.customer_managed_key[0].id, null)
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value       = local.diagnostic_settings_skipped
}
