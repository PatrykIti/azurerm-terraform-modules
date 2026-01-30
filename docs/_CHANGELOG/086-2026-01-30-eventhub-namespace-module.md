# Azure Event Hub Namespace module

**Date:** 2026-01-30

## Summary

Introduced the `azurerm_eventhub_namespace` module to manage Event Hub Namespaces, including namespace authorization rules, inline network rule set configuration, disaster recovery config, customer-managed keys, and diagnostic settings. Includes examples and tests aligned with repository standards.

## Scope

- New module: `modules/azurerm_eventhub_namespace`
- Authorization rules, DR config, CMK support
- Inline network rule set configuration
- Diagnostic settings with category discovery
- Examples: basic, complete, secure, network-rule-set, disaster-recovery

## Notes

Private endpoints, RBAC, and supporting networking resources remain out-of-scope and should be composed via dedicated modules or higher-level stacks.
