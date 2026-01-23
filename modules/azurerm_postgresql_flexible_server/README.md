# Terraform Azure PostgreSQL Flexible Server Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure PostgreSQL Flexible Server Terraform module with server-scoped features,
including configurations, firewall rules, Entra ID admin, virtual endpoints,
backups, and diagnostic settings.

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
  name     = "rg-pgfs-example"
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

  name                = "pgfsexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name            = "GP_Standard_D2s_v3"
  postgresql_version  = "15"

  administrator_login    = "pgfsadmin"
  administrator_password = random_password.admin.result

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Aad Auth](examples/aad-auth) - This example demonstrates enabling Microsoft Entra ID authentication and
- [Backup](examples/backup) - This example demonstrates creating a manual backup for a PostgreSQL Flexible
- [Basic](examples/basic) - This example demonstrates a minimal PostgreSQL Flexible Server deployment using
- [Complete](examples/complete) - This example demonstrates a comprehensive PostgreSQL Flexible Server
- [Configurations](examples/configurations) - This example demonstrates applying server configuration parameters using the
- [Customer Managed Key](examples/customer-managed-key) - This example demonstrates customer-managed key encryption using a user-assigned
- [Diagnostic Settings](examples/diagnostic-settings) - This example demonstrates streaming PostgreSQL Flexible Server logs and metrics
- [Firewall Rules](examples/firewall-rules) - This example demonstrates public network access with firewall rules for
- [Point In Time Restore](examples/point-in-time-restore) - This example demonstrates how to restore a PostgreSQL Flexible Server to a
- [Replica](examples/replica) - This example demonstrates creating a read replica using `create_mode = Replica`.
- [Secure](examples/secure) - This example demonstrates a hardened PostgreSQL Flexible Server deployment with
- [Virtual Endpoint](examples/virtual-endpoint) - This example demonstrates creating a virtual endpoint between a primary server
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
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_postgresql_flexible_server.postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_active_directory_administrator.active_directory_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server_active_directory_administrator) | resource |
| [azurerm_postgresql_flexible_server_backup.backups](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server_backup) | resource |
| [azurerm_postgresql_flexible_server_configuration.configurations](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.firewall_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [azurerm_postgresql_flexible_server_virtual_endpoint.virtual_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/postgresql_flexible_server_virtual_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_directory_administrator"></a> [active\_directory\_administrator](#input\_active\_directory\_administrator) | Entra ID administrator settings.<br/>Required when authentication.active\_directory\_auth\_enabled = true. Provide<br/>principal\_name, object\_id, principal\_type, and optionally tenant\_id. | <pre>object({<br/>    principal_name = string<br/>    object_id      = string<br/>    principal_type = string<br/>    tenant_id      = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Local administrator login for password authentication.<br/>Required when create\_mode is Default and password\_auth\_enabled is true. | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | Local administrator password for password authentication.<br/>Required when create\_mode is Default and password\_auth\_enabled is true. | `string` | `null` | no |
| <a name="input_authentication"></a> [authentication](#input\_authentication) | Authentication settings for the server.<br/>At least one method must be enabled. For Entra ID (AAD) set<br/>active\_directory\_auth\_enabled = true and provide active\_directory\_administrator<br/>plus tenant\_id (here or in the admin block). | <pre>object({<br/>    active_directory_auth_enabled = optional(bool, false)<br/>    password_auth_enabled         = optional(bool, true)<br/>    tenant_id                     = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Backup settings for the server.<br/>retention\_days must be 7-35. geo\_redundant\_backup\_enabled controls GRS backups.<br/>When using customer-managed keys with GRS, provide geo backup key and identity. | <pre>object({<br/>    retention_days               = optional(number, 7)<br/>    geo_redundant_backup_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_backups"></a> [backups](#input\_backups) | Manual backup definitions.<br/>Each entry creates a server-scoped backup with a unique name. | <pre>list(object({<br/>    name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_configurations"></a> [configurations](#input\_configurations) | List of server configuration name/value pairs.<br/>Names must be unique. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | Create mode for the server.<br/>Use Default for new servers. Replica/GeoRestore/ReviveDropped/PointInTimeRestore<br/>require source\_server\_id, and PointInTimeRestore requires<br/>point\_in\_time\_restore\_time\_in\_utc. | <pre>object({<br/>    mode                              = optional(string)<br/>    source_server_id                  = optional(string)<br/>    point_in_time_restore_time_in_utc = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key configuration using Azure Key Vault.<br/>Requires a user-assigned identity and a Key Vault key ID.<br/>primary\_user\_assigned\_identity\_id must be included in identity.identity\_ids.<br/>Geo backup key and identity are optional. | <pre>object({<br/>    key_vault_key_id                     = string<br/>    primary_user_assigned_identity_id    = string<br/>    geo_backup_key_vault_key_id          = optional(string)<br/>    geo_backup_user_assigned_identity_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for PostgreSQL Flexible Server logs and metrics.<br/>Each item creates a separate azurerm\_monitor\_diagnostic\_setting for the server.<br/>Provide explicit log\_categories and/or metric\_categories and at least one<br/>destination (Log Analytics, Storage, or Event Hub). Categories must be<br/>supported by Azure Monitor for this resource. | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules for public access.<br/>Only valid when public network access is enabled. Provide start and end IPv4 addresses. | <pre>list(object({<br/>    name             = string<br/>    start_ip_address = string<br/>    end_ip_address   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | High availability settings.<br/>mode can be ZoneRedundant or SameZone. When ZoneRedundant,<br/>standby\_availability\_zone is optional; if omitted Azure chooses the zone<br/>and may update it after failover. | <pre>object({<br/>    mode                      = string<br/>    standby_availability_zone = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration.<br/>type can be SystemAssigned, UserAssigned, or both. When UserAssigned is<br/>included, identity\_ids must be provided. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the server and all resources created by this module.<br/>Typically match the resource group location. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window in UTC.<br/>day\_of\_week is 0-6, start\_hour is 0-23, start\_minute is 0-59. | <pre>object({<br/>    day_of_week  = number<br/>    start_hour   = number<br/>    start_minute = number<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the PostgreSQL Flexible Server.<br/>Must be globally unique. 3-63 chars, lowercase letters, numbers, and hyphens. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network settings for the server.<br/>By default public access is enabled. For private access set<br/>public\_network\_access\_enabled = false and provide both delegated\_subnet\_id<br/>and private\_dns\_zone\_id. | <pre>object({<br/>    public_network_access_enabled = optional(bool)<br/>    delegated_subnet_id           = optional(string)<br/>    private_dns_zone_id           = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_postgresql_version"></a> [postgresql\_version](#input\_postgresql\_version) | PostgreSQL major version for the server.<br/>Allowed values are validated; choose a version supported in the region. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name where the server and server-scoped resources are created.<br/>The resource group must already exist. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the server (e.g. GP\_Standard\_D2s\_v3).<br/>Must be supported in the selected region and for the chosen version. | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Storage settings for the server.<br/>Leave empty to use Azure defaults. storage\_mb is in MB; storage\_tier must be valid. | <pre>object({<br/>    storage_mb   = optional(number)<br/>    storage_tier = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the server.<br/>Provide a map of string keys and values. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Custom timeouts for create, update, delete (e.g. "60m").<br/>Leave null to use provider defaults. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_virtual_endpoints"></a> [virtual\_endpoints](#input\_virtual\_endpoints) | Virtual endpoints for replicas.<br/>Each entry must include source\_server\_id or replica\_server\_id. type is ReadWrite. | <pre>list(object({<br/>    name              = string<br/>    source_server_id  = optional(string)<br/>    replica_server_id = optional(string)<br/>    type              = optional(string, "ReadWrite")<br/>  }))</pre> | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone for the primary server.<br/>Optional; if null Azure selects a zone. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_directory_administrator"></a> [active\_directory\_administrator](#output\_active\_directory\_administrator) | Active Directory administrator configuration for the PostgreSQL Flexible Server. |
| <a name="output_backups"></a> [backups](#output\_backups) | Map of PostgreSQL Flexible Server backups keyed by name. |
| <a name="output_configurations"></a> [configurations](#output\_configurations) | Map of PostgreSQL server configurations keyed by name. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | Map of PostgreSQL firewall rules keyed by name. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN of the PostgreSQL Flexible Server. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the PostgreSQL Flexible Server. |
| <a name="output_location"></a> [location](#output\_location) | The location of the PostgreSQL Flexible Server. |
| <a name="output_name"></a> [name](#output\_name) | The name of the PostgreSQL Flexible Server. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled for the PostgreSQL Flexible Server. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the PostgreSQL Flexible Server. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the PostgreSQL Flexible Server. |
| <a name="output_virtual_endpoints"></a> [virtual\_endpoints](#output\_virtual\_endpoints) | Map of PostgreSQL Flexible Server virtual endpoints keyed by name. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Extended documentation and scope notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing resources
