# ==============================================================================
# System-Assigned Identity Storage Account Outputs
# ==============================================================================

output "system_assigned_storage_account_id" {
  description = "The ID of the system-assigned identity storage account"
  value       = module.storage_system_assigned.id
}

output "system_assigned_storage_account_name" {
  description = "The name of the system-assigned identity storage account"
  value       = module.storage_system_assigned.name
}

output "system_assigned_principal_id" {
  description = "The principal ID of the system-assigned identity"
  value       = module.storage_system_assigned.identity.principal_id
}

output "system_assigned_tenant_id" {
  description = "The tenant ID of the system-assigned identity"
  value       = module.storage_system_assigned.identity.tenant_id
}

# ==============================================================================
# User-Assigned Identity Storage Account Outputs
# ==============================================================================

output "user_assigned_storage_account_id" {
  description = "The ID of the user-assigned identity storage account"
  value       = module.storage_user_assigned.id
}

output "user_assigned_storage_account_name" {
  description = "The name of the user-assigned identity storage account"
  value       = module.storage_user_assigned.name
}

output "user_assigned_identity_id" {
  description = "The ID of the user-assigned identity"
  value       = azurerm_user_assigned_identity.storage.id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the user-assigned identity"
  value       = azurerm_user_assigned_identity.storage.principal_id
}

# ==============================================================================
# Combined Identities Storage Account Outputs
# ==============================================================================

output "combined_storage_account_id" {
  description = "The ID of the combined identities storage account"
  value       = module.storage_combined.id
}

output "combined_storage_account_name" {
  description = "The name of the combined identities storage account"
  value       = module.storage_combined.name
}

output "combined_system_principal_id" {
  description = "The principal ID of the system-assigned identity for the combined account"
  value       = module.storage_combined.identity.principal_id
}

# ==============================================================================
# Key Vault Outputs
# ==============================================================================

output "key_vault_id" {
  description = "The ID of the Key Vault used for customer-managed keys"
  value       = azurerm_key_vault.example.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.example.name
}

output "storage_encryption_key_id" {
  description = "The ID of the storage encryption key"
  value       = azurerm_key_vault_key.storage.id
}

# ==============================================================================
# Testing Instructions
# ==============================================================================

output "testing_instructions" {
  description = "Instructions for testing identity-based access"
  value       = <<-EOT
    To test identity-based access:

    1. System-Assigned Identity:
       az storage blob list \
         --account-name ${module.storage_system_assigned.name} \
         --container-name system-test \
         --auth-mode login

    2. User-Assigned Identity (with CMK):
       az storage blob list \
         --account-name ${module.storage_user_assigned.name} \
         --container-name user-test \
         --auth-mode login

    3. Combined Identities (with CMK):
       az storage blob list \
         --account-name ${module.storage_combined.name} \
         --container-name combined-test \
         --auth-mode login

    Note: The current user has been granted 'Storage Blob Data Contributor' role for testing.
  EOT
}