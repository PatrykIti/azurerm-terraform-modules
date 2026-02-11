output "id" {
  description = "The ID of the Key Vault."
  value       = try(azurerm_key_vault.key_vault.id, null)
}

output "name" {
  description = "The name of the Key Vault."
  value       = try(azurerm_key_vault.key_vault.name, null)
}

output "location" {
  description = "The Azure region where the Key Vault is deployed."
  value       = try(azurerm_key_vault.key_vault.location, null)
}

output "resource_group_name" {
  description = "The resource group name containing the Key Vault."
  value       = try(azurerm_key_vault.key_vault.resource_group_name, null)
}

output "vault_uri" {
  description = "The URI of the Key Vault."
  value       = try(azurerm_key_vault.key_vault.vault_uri, null)
}

output "tenant_id" {
  description = "The tenant ID associated with the Key Vault."
  value       = try(azurerm_key_vault.key_vault.tenant_id, null)
}

output "sku_name" {
  description = "The SKU of the Key Vault."
  value       = try(azurerm_key_vault.key_vault.sku_name, null)
}

output "access_policies" {
  description = "Access policies managed by the module."
  value = {
    for name, policy in azurerm_key_vault_access_policy.access_policies : name => {
      id        = policy.id
      object_id = policy.object_id
      tenant_id = policy.tenant_id
    }
  }
}

output "keys" {
  description = "Key Vault keys managed by the module."
  value = {
    for name, key in azurerm_key_vault_key.keys : name => {
      id                      = key.id
      version                 = key.version
      versionless_id          = key.versionless_id
      resource_id             = key.resource_id
      resource_versionless_id = key.resource_versionless_id
      public_key_pem          = key.public_key_pem
      public_key_openssh      = key.public_key_openssh
    }
  }
}

output "secrets" {
  description = "Key Vault secrets managed by the module (metadata only)."
  value = {
    for name, secret in azurerm_key_vault_secret.secrets : name => {
      id                      = secret.id
      version                 = secret.version
      versionless_id          = secret.versionless_id
      resource_id             = secret.resource_id
      resource_versionless_id = secret.resource_versionless_id
    }
  }
}

output "certificates" {
  description = "Key Vault certificates managed by the module."
  value = {
    for name, cert in azurerm_key_vault_certificate.certificates : name => {
      id                              = cert.id
      secret_id                       = cert.secret_id
      version                         = cert.version
      versionless_id                  = cert.versionless_id
      versionless_secret_id           = cert.versionless_secret_id
      thumbprint                      = cert.thumbprint
      resource_manager_id             = cert.resource_manager_id
      resource_manager_versionless_id = cert.resource_manager_versionless_id
    }
  }
}

output "certificate_issuers" {
  description = "Key Vault certificate issuers managed by the module."
  value = {
    for name, issuer in azurerm_key_vault_certificate_issuer.issuers : name => {
      id            = issuer.id
      name          = issuer.name
      provider_name = issuer.provider_name
    }
  }
}

output "managed_storage_accounts" {
  description = "Managed storage accounts registered in the Key Vault."
  value = {
    for name, account in azurerm_key_vault_managed_storage_account.managed_storage_accounts : name => {
      id                           = account.id
      name                         = account.name
      storage_account_id           = account.storage_account_id
      regenerate_key_automatically = account.regenerate_key_automatically
    }
  }
}

output "managed_storage_sas_definitions" {
  description = "Managed storage SAS token definitions."
  value = {
    for name, definition in azurerm_key_vault_managed_storage_account_sas_token_definition.sas_definitions : name => {
      id                         = definition.id
      name                       = definition.name
      managed_storage_account_id = definition.managed_storage_account_id
      sas_type                   = definition.sas_type
      secret_id                  = definition.secret_id
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped."
  value       = []
}

output "tags" {
  description = "Tags applied to the Key Vault."
  value       = try(azurerm_key_vault.key_vault.tags, {})
}
