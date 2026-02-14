# Terraform Azure DevOps Service Endpoints Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps service endpoints module for managing a single generic service endpoint and strict-child permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "path/to/azuredevops_serviceendpoint"

  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "example-generic"
    server_url            = "https://example.endpoint.local"
    username              = "example-user"
    password              = "example-password"
  }

  serviceendpoint_permissions = [
    {
      key       = "project-admins"
      principal = "vssgp.Uy0xLTktMTIzNDU2"
      permissions = {
        Use        = "Allow"
        Administer = "Deny"
      }
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a single generic service endpoint.
- [Complete](examples/complete) - This example demonstrates creating multiple generic service endpoints using module-level for_each.
- [Secure](examples/secure) - This example demonstrates a service endpoint with explicit permission assignment.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing generic service endpoints into the module

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_serviceendpoint_generic.generic](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_generic) | resource |
| [azuredevops_serviceendpoint_permissions.permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_permissions) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_serviceendpoint_generic"></a> [serviceendpoint\_generic](#input\_serviceendpoint\_generic) | Generic service endpoint configuration managed by this module. | <pre>object({<br/>    service_endpoint_name = string<br/>    server_url            = string<br/>    username              = optional(string)<br/>    password              = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_serviceendpoint_permissions"></a> [serviceendpoint\_permissions](#input\_serviceendpoint\_permissions) | List of service endpoint permissions to assign to the endpoint created by this module. | <pre>list(object({<br/>    key         = optional(string)<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permissions"></a> [permissions](#output\_permissions) | Map of service endpoint permission IDs keyed by permission key. |
| <a name="output_serviceendpoint_id"></a> [serviceendpoint\_id](#output\_serviceendpoint\_id) | Service endpoint ID created by the module. |
| <a name="output_serviceendpoint_name"></a> [serviceendpoint\_name](#output\_serviceendpoint\_name) | Service endpoint name created by the module. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
