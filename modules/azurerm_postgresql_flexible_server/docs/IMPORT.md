# Import existing PostgreSQL Flexible Server into the module (Terraform import blocks)

This guide shows how to import an existing PostgreSQL Flexible Server into
`modules/azurerm_postgresql_flexible_server` using Terraform **import blocks**.

The flow is based on the **basic example** and keeps only the **module block**
in the configuration (no extra Terraform resources required).

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **server name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and keep just the **module block**. Replace values with your
existing server settings.

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "postgresql_flexible_server" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.0.0"

  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  server = {
    sku_name           = var.sku_name
    postgresql_version = var.postgresql_version
  }

  authentication = {
    administrator = {
      login    = var.administrator_login
      password = var.administrator_password
    }
  }
}
```

Create `terraform.tfvars` with real values:

```hcl
server_name          = "pgfs-prod"
resource_group_name  = "rg-database-prod"
location             = "westeurope"
sku_name             = "GP_Standard_D2s_v3"
postgresql_version   = "15"
administrator_login  = "pgfsadmin"
administrator_password = "<secret>"
```

Get current values with Azure CLI:

```bash
az postgres flexible-server show -g <rg> -n <server> --query '{name:name,location:location}' -o table
```

---

## 2) Add the import block(s)

Create `import.tf` with the server import block:

```hcl
import {
  to = module.postgresql_flexible_server.azurerm_postgresql_flexible_server.postgresql_flexible_server
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<server>"
}
```

To get the **exact ID**:

```bash
az postgres flexible-server show -g <rg> -n <server> --query id -o tsv
```

### Optional imports

If you want the module to manage additional server-scoped resources, import them
after defining the matching inputs:

**Configurations**
```hcl
import {
  to = module.postgresql_flexible_server.azurerm_postgresql_flexible_server_configuration.postgresql_flexible_server_configuration["log_connections"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<server>/configurations/log_connections"
}
```

**Firewall rules**
```hcl
import {
  to = module.postgresql_flexible_server.azurerm_postgresql_flexible_server_firewall_rule.postgresql_flexible_server_firewall_rule["office-range"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<server>/firewallRules/office-range"
}
```

**Active Directory administrator**
```hcl
import {
  to = module.postgresql_flexible_server.azurerm_postgresql_flexible_server_active_directory_administrator.postgresql_flexible_server_active_directory_administrator[0]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<server>/administrators/<principal_name>"
}
```

**Virtual endpoints**
```hcl
import {
  to = module.postgresql_flexible_server.azurerm_postgresql_flexible_server_virtual_endpoint.postgresql_flexible_server_virtual_endpoint["primary-replica-endpoint"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<server>/virtualEndpoints/primary-replica-endpoint"
}
```

**Backups**
```hcl
import {
  to = module.postgresql_flexible_server.azurerm_postgresql_flexible_server_backup.postgresql_flexible_server_backup["manual-backup-001"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<server>/backups/manual-backup-001"
}
```

Use the Azure CLI to confirm IDs:

```bash
az postgres flexible-server configuration show -g <rg> -s <server> -n <config> --query id -o tsv
az postgres flexible-server firewall-rule show -g <rg> -s <server> -n <rule> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the server
- **no other changes** (unless you plan to manage sub-resources)

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg postgresql_flexible_server
```

If the plan is clean, you can **remove the import block** (`import.tf`).

---

## Common errors and fixes

- **Import does nothing**: import blocks run only on `terraform apply`. Run `plan` then `apply`.
- **Resource not found**: wrong ID or subscription. Use `az account show` and the CLI commands above.
- **Plan shows changes after import**: inputs do not match existing server configuration.
- **Database resources**: `azurerm_postgresql_flexible_server_database` is out of scope for this module.
