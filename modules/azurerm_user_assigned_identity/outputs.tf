output "id" {
  description = "The ID of the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.id, null)
}

output "name" {
  description = "The name of the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.name, null)
}

output "location" {
  description = "The location of the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.location, null)
}

output "resource_group_name" {
  description = "The resource group name containing the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.resource_group_name, null)
}

output "client_id" {
  description = "The client ID of the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.client_id, null)
}

output "principal_id" {
  description = "The principal ID of the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.tenant_id, null)
}

output "tags" {
  description = "The tags assigned to the User Assigned Identity."
  value       = try(azurerm_user_assigned_identity.main.tags, null)
}

output "federated_identity_credentials" {
  description = "Map of federated identity credentials keyed by name."
  value = try({
    for name, credential in azurerm_federated_identity_credential.main :
    name => {
      id       = credential.id
      name     = credential.name
      issuer   = credential.issuer
      subject  = credential.subject
      audience = credential.audience
    }
  }, {})
}
