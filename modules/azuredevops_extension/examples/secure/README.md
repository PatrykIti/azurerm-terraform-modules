# Secure Azure DevOps Extension Example

This example demonstrates installing only approved Azure DevOps Marketplace extensions using an allowlist.

## Features

- Explicit allowlist of extensions
- Optional version pinning for approved extensions

## Key Configuration

Maintain `approved_extensions` as your vetted list of Marketplace extensions.
The module uses `for_each` to install only approved entries.

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
| <a name="input_approved_extensions"></a> [approved\_extensions](#input\_approved\_extensions) | Allowlist of approved extensions to install. | <pre>list(object({<br/>    publisher_id = string<br/>    extension_id = string<br/>    version      = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "extension_id": "approved-extension",<br/>    "publisher_id": "approved-publisher"<br/>  }<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_extension_ids"></a> [extension\_ids](#output\_extension\_ids) | Map of extension IDs keyed by publisher/extension. |
<!-- END_TF_DOCS -->
