# Event Hub Module Documentation

## Overview

This module provisions Event Hubs and their direct sub-resources (consumer
groups and authorization rules). Namespace creation and network isolation are
managed outside of this module.

## Managed Resources

- `azurerm_eventhub`
- `azurerm_eventhub_consumer_group`
- `azurerm_eventhub_authorization_rule`

## Usage Notes

 - `namespace_id` is required and must reference an existing Event Hub Namespace.
- `partition_count` cannot be decreased; increases depend on namespace SKU.
- Capture requires Blob Storage and a valid archive name format.
- `message_retention` and `retention_description` are mutually exclusive.

## Out of Scope

- Event Hub Namespace provisioning
- Private endpoints and Private DNS zones
- RBAC/role assignments and policies
- Storage account provisioning (capture destination)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
