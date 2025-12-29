# Basic Azure DevOps Extension Example

This example demonstrates installing a single Azure DevOps Marketplace extension.

## Features

- Installs one extension at the organization level
- Optional version pinning

## Key Configuration

Provide the Marketplace `publisher_id` and `extension_id` (and optionally `extension_version`).

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
| <a name="module_azuredevops_extension"></a> [azuredevops\_extension](#module\_azuredevops\_extension) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extension_id"></a> [extension\_id](#input\_extension\_id) | Extension ID from the Marketplace. | `string` | `"extension-id"` | no |
| <a name="input_extension_version"></a> [extension\_version](#input\_extension\_version) | Optional extension version to pin. | `string` | `null` | no |
| <a name="input_publisher_id"></a> [publisher\_id](#input\_publisher\_id) | Publisher ID of the extension. | `string` | `"publisher-id"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_extension_id"></a> [extension\_id](#output\_extension\_id) | ID of the installed Azure DevOps extension. |
<!-- END_TF_DOCS -->
