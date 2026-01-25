# Importing PostgreSQL Flexible Server Databases

Use this guide to import existing PostgreSQL Flexible Server databases into the
module state.

## Prerequisites

- Terraform >= 1.12.2
- Access to the PostgreSQL Flexible Server and database
- Database name and server resource ID

## Minimal Module Configuration

```hcl
module "postgresql_flexible_server_database" {
  source = "github.com/<org>/<repo>//modules/azurerm_postgresql_flexible_server_database?ref=PGFSDBv1.0.0"

  server_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfs-example"
  name      = "appdb"
}
```

## Import Block

```hcl
import {
  to = module.postgresql_flexible_server_database.azurerm_postgresql_flexible_server_database.postgresql_flexible_server_database
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.DBforPostgreSQL/flexibleServers/pgfs-example/databases/appdb"
}
```

## Verification

After running `terraform plan`, verify that:

- No changes are proposed for the imported database.
- `charset` and `collation` match the server-side configuration (when set).

## Common Errors

- **Invalid server ID**: Ensure `server_id` points to the hosting flexible server.
- **Mismatched database name**: `name` must match the database segment
  in the import ID.
