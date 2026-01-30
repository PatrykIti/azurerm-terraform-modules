# Key Vault Module Documentation

## Overview

This module provisions an Azure Key Vault and optional data-plane resources
(keys, secrets, certificates, certificate issuers, managed storage accounts, and SAS definitions).
Diagnostic settings are managed inline.

## Managed Resources

- azurerm_key_vault
- azurerm_key_vault_access_policy
- azurerm_key_vault_key
- azurerm_key_vault_secret
- azurerm_key_vault_certificate
- azurerm_key_vault_certificate_issuer
- azurerm_key_vault_managed_storage_account
- azurerm_key_vault_managed_storage_account_sas_token_definition
- azurerm_monitor_diagnostic_setting

## Usage Notes

- RBAC and access policies are mutually exclusive.
- Key Vault data-plane resources require access policies or RBAC roles that allow creation.
- Managed storage accounts require storage account IDs and access keys.
- Diagnostic settings use category discovery to enable only supported categories.

## Out-of-scope Resources

The following are intentionally out of scope for this module and should be
managed by dedicated modules or environment configuration:

- Private endpoints and Private DNS
- Role assignments and RBAC bindings
- Virtual networks and subnets
- Storage accounts and Log Analytics workspaces
