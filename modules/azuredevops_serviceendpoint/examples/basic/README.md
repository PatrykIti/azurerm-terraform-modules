# Basic Azure DevOps Service Endpoints Example

This example demonstrates creating a single generic service endpoint.

## Features

- Generic service connection
- Minimal required inputs

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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_serviceendpoint"></a> [azuredevops\_serviceendpoint](#module\_azuredevops\_serviceendpoint) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_generic_endpoint_name"></a> [generic\_endpoint\_name](#input\_generic\_endpoint\_name) | Generic service endpoint name. | `string` | `"ado-generic-basic"` | no |
| <a name="input_generic_endpoint_password"></a> [generic\_endpoint\_password](#input\_generic\_endpoint\_password) | Generic service endpoint password. | `string` | n/a | yes |
| <a name="input_generic_endpoint_url"></a> [generic\_endpoint\_url](#input\_generic\_endpoint\_url) | Generic service endpoint URL. | `string` | `"https://example.endpoint.local"` | no |
| <a name="input_generic_endpoint_username"></a> [generic\_endpoint\_username](#input\_generic\_endpoint\_username) | Generic service endpoint username. | `string` | `"example-user"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_serviceendpoint_id"></a> [serviceendpoint\_id](#output\_serviceendpoint\_id) | Service endpoint ID created by the module. |
| <a name="output_serviceendpoint_name"></a> [serviceendpoint\_name](#output\_serviceendpoint\_name) | Service endpoint name created by the module. |
<!-- END_TF_DOCS -->
