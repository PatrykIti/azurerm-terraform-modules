# Azure Event Hub module

**Date:** 2026-01-30

## Summary

Introduced the `azurerm_eventhub` module to manage Event Hubs within an existing namespace, including capture configuration, retention description, consumer groups, and authorization rules. Includes examples and tests aligned with repository standards.

## Scope

- New module: `modules/azurerm_eventhub`
- Capture configuration with Blob Storage destination
- Retention description and status configuration
- Consumer groups and authorization rules
- Examples: basic, complete, secure, capture, consumer-groups

## Notes

Namespace provisioning, private endpoints, RBAC, and storage account creation remain out-of-scope and should be composed via dedicated modules or higher-level stacks.
