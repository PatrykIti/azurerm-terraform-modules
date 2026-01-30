# AI Services Account Module Documentation

## Overview

This module manages an Azure AI Services Account using the `azurerm_ai_services` resource
from the AzureRM provider (the provider uses `azurerm_ai_services` for AI Services Accounts).

## Managed Resources

- `azurerm_ai_services` (AI Services Account)
- `azurerm_monitor_diagnostic_setting` (optional; one or more diagnostic settings)
- `azurerm_monitor_diagnostic_categories` (data source for category discovery)

## Usage Notes

- `custom_subdomain_name` is required when `network_acls` is provided.
- `customer_managed_key` requires a user-assigned identity and `identity.identity_ids`.
- Diagnostic settings support `areas` to map to available log/metric categories.

## Out of Scope

- AI deployments/models and RAI policies/blocklists (not exposed by azurerm for AI Services Accounts in 4.57.0)
- Private endpoints and Private DNS configuration
- RBAC/role assignments and budgets
- Provisioning user-assigned identities or Key Vault resources (accepts IDs only)
