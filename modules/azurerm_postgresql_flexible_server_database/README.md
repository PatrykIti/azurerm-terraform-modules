# Terraform Azure PostgreSQL Flexible Server Database Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages PostgreSQL databases hosted by an existing Azure PostgreSQL Flexible Server.

## Usage

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-pgfsdb-example"
  location = "westeurope"
}

resource "random_password" "admin" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

module "postgresql_flexible_server" {
  source = "path/to/azurerm_postgresql_flexible_server"

  name                = "pgfsdbexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server = {
    sku_name           = "GP_Standard_D2s_v3"
    postgresql_version = "15"
  }

  authentication = {
    administrator = {
      login    = "pgfsadmin"
      password = random_password.admin.result
    }
  }
}

module "postgresql_flexible_server_database" {
  source = "path/to/azurerm_postgresql_flexible_server_database"

  server_id = module.postgresql_flexible_server.id
  name      = "appdb"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic PostgreSQL Flexible Server Database configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of PostgreSQL Flexible Server Database with all available features and configurations.
- [Secure](examples/secure) - This example demonstrates a private-networked PostgreSQL Flexible Server with a database created through the module.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_postgresql_flexible_server_database.postgresql_flexible_server_database](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_charset"></a> [charset](#input\_charset) | Optional database charset (e.g. UTF8). | `string` | `null` | no |
| <a name="input_collation"></a> [collation](#input\_collation) | Optional database collation (e.g. en\_US.utf8). | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | PostgreSQL database name. | `string` | n/a | yes |
| <a name="input_server_id"></a> [server\_id](#input\_server\_id) | Resource ID of the PostgreSQL Flexible Server hosting the database. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_charset"></a> [charset](#output\_charset) | The charset of the PostgreSQL Flexible Server Database. |
| <a name="output_collation"></a> [collation](#output\_collation) | The collation of the PostgreSQL Flexible Server Database. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the PostgreSQL Flexible Server Database. |
| <a name="output_name"></a> [name](#output\_name) | The name of the PostgreSQL Flexible Server Database. |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | The server ID hosting the PostgreSQL Flexible Server Database. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Extended documentation and scope notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing resources
