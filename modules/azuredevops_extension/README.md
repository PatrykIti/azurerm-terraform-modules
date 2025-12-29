# Terraform Azure DevOps Extension Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps extension module for managing a single Marketplace extension.
Use module-level `for_each` to install multiple extensions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_extension" {
  source = "path/to/azuredevops_extension"

  publisher_id      = "publisher-id"
  extension_id      = "extension-id"
  extension_version = "1.2.3"
}
```

Note: Terraform reserves the module argument `version`, so the optional pin is exposed as `extension_version`.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates installing a single Azure DevOps Marketplace extension.
- [Complete](examples/complete) - This example demonstrates installing multiple Azure DevOps Marketplace extensions with version pinning.
- [Secure](examples/secure) - This example demonstrates installing only approved Azure DevOps Marketplace extensions using an allowlist.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps extensions into the module


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
| [azuredevops_extension.extension](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extension_id"></a> [extension\_id](#input\_extension\_id) | Extension ID from the Marketplace. | `string` | n/a | yes |
| <a name="input_extension_version"></a> [extension\_version](#input\_extension\_version) | Optional extension version to pin. | `string` | `null` | no |
| <a name="input_publisher_id"></a> [publisher\_id](#input\_publisher\_id) | Publisher ID of the extension. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_extension_id"></a> [extension\_id](#output\_extension\_id) | The ID of the Azure DevOps extension. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
