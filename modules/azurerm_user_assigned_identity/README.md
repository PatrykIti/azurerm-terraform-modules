# Terraform Azure User Assigned Identity Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure User Assigned Identities and federated identity credentials.

## Usage

```hcl
module "azurerm_user_assigned_identity" {
  source = "path/to/azurerm_user_assigned_identity"

  name                = "uai-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "github-actions"
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:example-org/example-repo:ref:refs/heads/main"
      audience = ["api://AzureADTokenExchange"]
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a single User Assigned Identity with default settings.
- [Complete](examples/complete) - This example demonstrates a User Assigned Identity with federated identity credentials and custom timeouts.
- [Federated Identity Credentials](examples/federated-identity-credentials) - This example focuses on configuring federated identity credentials for a User Assigned Identity.
- [Github Actions Oidc](examples/github-actions-oidc) - This example shows how to configure a federated identity credential for GitHub Actions
- [Secure](examples/secure) - This example demonstrates a User Assigned Identity with a federated identity credential and least-privilege RBAC applied outside the module.
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
| [azurerm_federated_identity_credential.federated_identity_credential](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/federated_identity_credential) | resource |
| [azurerm_user_assigned_identity.user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_federated_identity_credential_timeouts"></a> [federated\_identity\_credential\_timeouts](#input\_federated\_identity\_credential\_timeouts) | Optional timeouts applied to all federated identity credential operations. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_federated_identity_credentials"></a> [federated\_identity\_credentials](#input\_federated\_identity\_credentials) | List of federated identity credentials to associate with this User Assigned Identity.<br/><br/>Each entry must include:<br/>- name: 3-120 characters, start with a letter or number, contain only letters, numbers, hyphens, or underscores.<br/>- issuer: HTTPS issuer URL.<br/>- subject: non-empty subject claim.<br/>- audience: non-empty list of audience values. | <pre>list(object({<br/>    name     = string<br/>    issuer   = string<br/>    subject  = string<br/>    audience = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the User Assigned Identity should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the User Assigned Identity. Must be 3-128 characters, start with a letter or number, and contain only letters, numbers, hyphens, or underscores. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the User Assigned Identity. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the User Assigned Identity. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for User Assigned Identity operations. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The client ID of the User Assigned Identity. |
| <a name="output_federated_identity_credentials"></a> [federated\_identity\_credentials](#output\_federated\_identity\_credentials) | Map of federated identity credentials keyed by name. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the User Assigned Identity. |
| <a name="output_location"></a> [location](#output\_location) | The location of the User Assigned Identity. |
| <a name="output_name"></a> [name](#output\_name) | The name of the User Assigned Identity. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the User Assigned Identity. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name containing the User Assigned Identity. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the User Assigned Identity. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the User Assigned Identity. |
<!-- END_TF_DOCS -->

## Security Considerations

- Federated identity credentials define trust boundaries. Ensure `issuer`, `subject`, and `audience` are scoped to the exact workload.
- Avoid broad subjects and wildcard claims; use environment-specific subjects where possible.
- Apply least-privilege RBAC outside the module when granting access to Azure resources.

## Module Documentation

- [docs/README.md](docs/README.md) - Extended documentation and scope notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing resources

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
