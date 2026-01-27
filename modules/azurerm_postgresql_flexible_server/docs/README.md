# PostgreSQL Flexible Server Module Documentation

## Overview

This module provisions a single Azure PostgreSQL Flexible Server and manages
server-scoped resources such as configurations, firewall rules, Entra ID
administrator, virtual endpoints, backups, and diagnostic settings. The module
is atomic and intentionally avoids cross-resource glue.

## Managed Resources

- `azurerm_postgresql_flexible_server`
- `azurerm_postgresql_flexible_server_configuration`
- `azurerm_postgresql_flexible_server_firewall_rule`
- `azurerm_postgresql_flexible_server_active_directory_administrator`
- `azurerm_postgresql_flexible_server_virtual_endpoint`
- `azurerm_postgresql_flexible_server_backup`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- **Authentication**: Password auth is enabled by default. Enable Entra ID
  authentication by setting `authentication.active_directory_auth_enabled = true`
  and providing `active_directory_administrator` details.
- **Private networking**: Set `network.public_network_access_enabled = false`.
  For delegated subnet private access, provide both
  `network.delegated_subnet_id` and `network.private_dns_zone_id`. You can also
  disable public access without delegated networking and manage private
  endpoints outside this module.
- **Customer-managed keys**: Requires a user-assigned identity and a Key Vault
  key URL. The user-assigned identity must have access to the key.
- **Create modes**: Restore/replica modes require `create_mode.source_server_id`.

## Out of Scope

The following are intentionally managed outside this module:

- PostgreSQL databases (`azurerm_postgresql_flexible_server_database`)
- Private endpoints and Private DNS zone links (except IDs passed into inputs)
- Role assignments / RBAC / budgets
- Hub-and-spoke networking and shared VNet resources

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
