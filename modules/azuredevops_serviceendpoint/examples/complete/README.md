# Complete Azure DevOps Service Endpoints Example

This example demonstrates creating multiple service endpoints using module-level for_each.

## Features

- Generic service endpoint
- Incoming webhook service endpoint
- Permissions applied to the module-created endpoint

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
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_serviceendpoint"></a> [azuredevops\_serviceendpoint](#module\_azuredevops\_serviceendpoint) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_group.project_collection_admins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_generic_endpoint_name"></a> [generic\_endpoint\_name](#input\_generic\_endpoint\_name) | Generic service endpoint name. | `string` | `"ado-generic-complete"` | no |
| <a name="input_generic_endpoint_password"></a> [generic\_endpoint\_password](#input\_generic\_endpoint\_password) | Generic service endpoint password. | `string` | n/a | yes |
| <a name="input_generic_endpoint_url"></a> [generic\_endpoint\_url](#input\_generic\_endpoint\_url) | Generic service endpoint URL. | `string` | `"https://example.endpoint.local"` | no |
| <a name="input_generic_endpoint_username"></a> [generic\_endpoint\_username](#input\_generic\_endpoint\_username) | Generic service endpoint username. | `string` | `"example-user"` | no |
| <a name="input_incoming_webhook_endpoint_name"></a> [incoming\_webhook\_endpoint\_name](#input\_incoming\_webhook\_endpoint\_name) | Incoming webhook service endpoint name. | `string` | `"ado-incoming-webhook"` | no |
| <a name="input_incoming_webhook_secret"></a> [incoming\_webhook\_secret](#input\_incoming\_webhook\_secret) | Incoming webhook secret. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permissions"></a> [permissions](#output\_permissions) | Service endpoint permission IDs created by the module instances. |
| <a name="output_serviceendpoint_ids"></a> [serviceendpoint\_ids](#output\_serviceendpoint\_ids) | Service endpoint IDs created by the module instances. |
<!-- END_TF_DOCS -->
