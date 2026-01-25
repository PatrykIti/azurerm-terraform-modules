# PostgreSQL Flexible Server Database Module Documentation

## Overview

This module provisions a single PostgreSQL database on an existing Azure
PostgreSQL Flexible Server. The module is atomic and intentionally avoids
cross-resource glue.

## Managed Resources

- `azurerm_postgresql_flexible_server_database`

## Usage Notes

- **Server dependency**: The database is created on an existing server by
  providing `server.id`.
- **Charset and collation**: Optional fields for database-level configuration.
  When set, ensure they are valid for the chosen PostgreSQL version.

## Out of Scope

The following are intentionally managed outside this module:

- PostgreSQL Flexible Server (`azurerm_postgresql_flexible_server`)
- Networking (private endpoints, VNet integration, DNS zones)
- Authentication and identity configuration
- Diagnostic settings and monitoring

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
