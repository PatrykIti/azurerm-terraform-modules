# Secure PostgreSQL Flexible Server Database Example

This example demonstrates a private-networked PostgreSQL Flexible Server with a database created through the module.

## Features

- Private networking via delegated subnet and private DNS zone
- Database creation on a private server

## Key Configuration

This example focuses on disabling public access and keeping traffic on private network paths.

## Security Considerations

- Public network access is disabled on the server
- Access is limited to the private subnet

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgresql_flexible_server"></a> [postgresql\_flexible\_server](#module\_postgresql\_flexible\_server) | ../../../azurerm_postgresql_flexible_server | n/a |
| <a name="module_postgresql_flexible_server_database"></a> [postgresql\_flexible\_server\_database](#module\_postgresql\_flexible\_server\_database) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |
| [azurerm_subnet.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_network) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Administrator login for the PostgreSQL Flexible Server. | `string` | `"pgfsadmin"` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | PostgreSQL database name. | `string` | `"appdbsecure"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the example. | `string` | `"westeurope"` | no |
| <a name="input_postgresql_version"></a> [postgresql\_version](#input\_postgresql\_version) | PostgreSQL version for the server. | `string` | `"15"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group for the example. | `string` | `"rg-pgfsdb-secure-example"` | no |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | PostgreSQL Flexible Server name (must be globally unique). | `string` | `"pgfsdbsecureexample001"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the PostgreSQL Flexible Server. | `string` | `"GP_Standard_D2s_v3"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Delegated subnet name for the private server. | `string` | `"snet-pgfsdb-secure-example"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Virtual network name for the private server. | `string` | `"vnet-pgfsdb-secure-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_postgresql_flexible_server_database_id"></a> [postgresql\_flexible\_server\_database\_id](#output\_postgresql\_flexible\_server\_database\_id) | The ID of the created PostgreSQL Flexible Server Database |
| <a name="output_postgresql_flexible_server_database_name"></a> [postgresql\_flexible\_server\_database\_name](#output\_postgresql\_flexible\_server\_database\_name) | The name of the created PostgreSQL Flexible Server Database |
<!-- END_TF_DOCS -->
