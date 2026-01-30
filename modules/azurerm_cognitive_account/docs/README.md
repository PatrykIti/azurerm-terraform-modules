# Cognitive Account Module Documentation

## Overview

The `azurerm_cognitive_account` module provisions Azure Cognitive Services accounts for OpenAI, Language (TextAnalytics), and Speech workloads. It supports optional OpenAI sub-resources (deployments, RAI policies, and blocklists) and integrates diagnostic settings.

## Managed Resources

- `azurerm_cognitive_account`
- `azurerm_cognitive_deployment` (OpenAI only)
- `azurerm_cognitive_account_rai_policy` (OpenAI only)
- `azurerm_cognitive_account_rai_blocklist` (OpenAI only)
- `azurerm_cognitive_account_customer_managed_key` (optional, when managed separately)
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- The module supports `kind` values: `OpenAI`, `TextAnalytics` (Language), `Speech`, and `SpeechServices`. `Language` is accepted and normalized to `TextAnalytics`.
- OpenAI sub-resources (deployments, RAI policies, blocklists) require `kind = "OpenAI"`.
- `custom_subdomain_name` is required when `network_acls` is set, and is also required for private endpoints created outside the module.
- Customer-managed keys require a user-assigned identity with access to the Key Vault key.
- `storage` blocks are not supported for OpenAI accounts.
- SKU availability varies by service and region; validate SKU/kind combinations in Azure before applying.
- Use either inline CMK configuration or the separate `azurerm_cognitive_account_customer_managed_key` resource via `use_separate_resource`; do not mix both.

## Out of Scope

This module does not manage:

- Private endpoints, Private DNS zones, or VNet links
- Role assignments / RBAC
- Networking glue (VNets, subnets, NSGs, UDRs)
- Log Analytics workspaces or Event Hubs
- Key Vaults, Managed HSMs, or user-assigned identities (only IDs are accepted)
- `azurerm_ai_services_account` (managed in a separate module)

## Additional References

- [Import documentation](IMPORT.md)
- [Security considerations](../SECURITY.md)
