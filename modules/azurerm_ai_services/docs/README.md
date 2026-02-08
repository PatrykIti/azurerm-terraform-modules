# AI Services Module Documentation

## Overview

This module manages Azure AI Services using the `azurerm_ai_services` resource
from the AzureRM provider.

## Managed Resources

- `azurerm_ai_services` (AI Services)
- `azurerm_monitor_diagnostic_setting` (optional; one or more diagnostic settings)

## Usage Notes

- `custom_subdomain_name` is required when `network_acls` is provided.
- `customer_managed_key` requires a user-assigned identity and `identity.identity_ids`.
- Diagnostic settings use explicit categories validated in `variables.tf`.

## Out of Scope

- AI deployments/models and RAI policies/blocklists (not exposed by azurerm for AI Services Accounts in 4.57.0)
- Private endpoints and Private DNS configuration
- RBAC/role assignments and budgets
- Provisioning user-assigned identities or Key Vault resources (accepts IDs only)
