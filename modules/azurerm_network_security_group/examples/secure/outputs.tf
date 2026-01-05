output "network_security_group_id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "network_security_group_name" {
  description = "The name of the created Network Security Group."
  value       = module.network_security_group.name
}

output "application_security_group_ids" {
  description = "Map of Application Security Group names to their IDs."
  value = {
    web_tier = azurerm_application_security_group.web_tier.id
    app_tier = azurerm_application_security_group.app_tier.id
    db_tier  = azurerm_application_security_group.db_tier.id
  }
}
